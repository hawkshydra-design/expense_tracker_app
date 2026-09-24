/// Result of parsing a UPI/bank notification.
class ParsedTransaction {
  final double amount;
  final String? merchant;
  final bool isDebit;
  final String? upiRef;
  final String rawText;
  final String sourceApp;

  const ParsedTransaction({
    required this.amount,
    this.merchant,
    required this.isDebit,
    this.upiRef,
    required this.rawText,
    required this.sourceApp,
  });

  @override
  String toString() =>
      'ParsedTransaction(₹$amount, merchant: $merchant, '
      'debit: $isDebit, ref: $upiRef, app: $sourceApp)';
}

/// Regex-based parser that extracts transaction details from
/// Indian UPI / bank notification text.
///
/// Supports formats from Google Pay, Paytm, PhonePe, BHIM,
/// and most Indian bank SMS/push notifications.
///
/// Handles both P2M (person-to-merchant) and P2P (person-to-person)
/// transaction notification formats including:
///   - "You paid ₹500 to Swiggy"           (P2M standard)
///   - "₹20 sent to +91XXXXXXXX"           (P2P phone number)
///   - "Payment of ₹200 to auto driver"     (P2P casual)
///   - "Paid ₹100"                          (minimal format)
///   - "You sent ₹500 to Name on UPI"       (GPay P2P)
///   - "Debited ₹1,200 from A/c XX1234"     (Bank SMS)
///   - "Rs.500 debited from SBI A/c"        (Bank SMS variant)
class TransactionParser {
  TransactionParser._();

  // ─── Amount patterns ───────────────────────────────────────
  // Matches: ₹500, Rs.1,200.50, INR 999, Rs 50, Rupees 100
  // Also handles: "of ₹200", "for ₹500" (common in P2P formats)
  static final _amountRegex = RegExp(
    r'(?:Rs\.?\s?|₹\s?|INR\s?|Rupees?\s?)\s*([0-9,]+(?:\.[0-9]{1,2})?)',
    caseSensitive: false,
  );

  // ─── Debit indicators ─────────────────────────────────────
  static final _debitRegex = RegExp(
    r'(?:debited|debit|sent|paid|spent|purchase|payment|transferred|withdrawn|charged|paying|pay\b)',
    caseSensitive: false,
  );

  // ─── Credit indicators ────────────────────────────────────
  static final _creditRegex = RegExp(
    r'(?:credited|credit|received|refund|cashback|reversed|deposited)',
    caseSensitive: false,
  );

  // ─── Merchant extraction (P2M standard) ────────────────────
  // Matches: "to Swiggy", "at Amazon", "paid to Zomato"
  static final _merchantRegex = RegExp(
    r"(?:to|at|paid\s+to|transferred\s+to|sent\s+to)\s+([A-Za-z0-9][\w\s.&\-']*?)(?:\s+(?:on|via|UPI|Ref|using|through|for|$)|\.|$)",
    caseSensitive: false,
  );

  // ─── UPI Reference number ─────────────────────────────────
  static final _upiRefRegex = RegExp(
    r'(?:UPI\s?(?:Ref|ref|REF)\.?\s*(?:No\.?\s*)?:?\s*)(\d{6,})',
    caseSensitive: false,
  );

  // ─── Alternative merchant: "from <merchant>" for debits ───
  static final _merchantFromRegex = RegExp(
    r"(?:from)\s+([A-Za-z0-9][\w\s.&\-']*?)(?:\s+(?:on|via|UPI|Ref|$)|\.|$)",
    caseSensitive: false,
  );

  // ─── VPA-based merchant (bank SMS format) ─────────────────
  // Matches: "to VPA merchant@upi", "to VPA name@paytm"
  static final _vpaRegex = RegExp(
    r'(?:VPA|vpa|UPI ID)\s*:?\s*([\w.\-]+)@([\w]+)',
    caseSensitive: false,
  );

  // ─── Bank SMS "to <name>" with A/c or UPI context ─────────
  // Matches: "transferred to JOHN DOE", "to VPA merchant@bank"
  static final _bankSmsMerchantRegex = RegExp(
    r"(?:to|towards)\s+(?:VPA\s+)?([A-Za-z][A-Za-z\s.]+?)(?:\s*@|\s+(?:on|UPI|Ref|via|A/c|Avl|Bal|If|linked|$)|\.|$)",
    caseSensitive: false,
  );

  // ─── P2P: Phone number as merchant ────────────────────────
  // Matches: "to +91XXXXXXXXXX", "to 9876543210"
  static final _phoneNumberRegex = RegExp(
    r'(?:to|sent\s+to)\s+(\+?91[\s-]?\d{10}|\d{10})\b',
    caseSensitive: false,
  );

  // ─── GPay specific P2P format ─────────────────────────────
  // Matches: "You sent ₹500 to Name" or "Sent ₹200 to Name"
  static final _gpaySentRegex = RegExp(
    r"(?:You\s+)?sent\s+(?:Rs\.?\s?|₹\s?|INR\s?)\s*[0-9,]+(?:\.[0-9]{1,2})?\s+to\s+([A-Za-z][\w\s.&\-']+?)(?:\s+(?:on|via|UPI|$)|\.|$)",
    caseSensitive: false,
  );

  // ─── PhonePe specific format ──────────────────────────────
  // Matches: "Payment of ₹200 to Name was successful"
  static final _phonePePaymentRegex = RegExp(
    r"Payment\s+of\s+(?:Rs\.?\s?|₹\s?|INR\s?)\s*[0-9,]+(?:\.[0-9]{1,2})?\s+to\s+([A-Za-z0-9][\w\s.&\-']*?)(?:\s+(?:was|is|has|on|via|$)|\.|$)",
    caseSensitive: false,
  );



  /// Parse a notification body text into a [ParsedTransaction].
  ///
  /// Returns `null` if:
  /// - No amount could be extracted
  /// - The transaction appears to be a credit/income (not a debit)
  static ParsedTransaction? parse({
    required String text,
    required String sourceApp,
  }) {
    if (text.isEmpty) return null;

    // 1. Extract amount
    final amountMatch = _amountRegex.firstMatch(text);
    if (amountMatch == null) return null;

    final amountStr = amountMatch.group(1)!.replaceAll(',', '');
    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) return null;

    // 2. Determine debit vs credit
    final hasDebit = _debitRegex.hasMatch(text);
    final hasCredit = _creditRegex.hasMatch(text);

    // If explicitly credit and not debit, skip (it's income, not expense)
    if (hasCredit && !hasDebit) return null;

    // Default to debit if no clear indicator (most UPI notifications
    // for payments don't always say "debited")
    final isDebit = hasDebit || !hasCredit;

    // 3. Extract merchant name (try multiple strategies)
    String? merchant;

    // Strategy A: Try GPay-specific "sent ₹X to Name" format
    final gpayMatch = _gpaySentRegex.firstMatch(text);
    if (gpayMatch != null) {
      merchant = _cleanMerchant(gpayMatch.group(1)!);
    }

    // Strategy B: Try PhonePe "Payment of ₹X to Name" format
    if (merchant == null) {
      final phonePeMatch = _phonePePaymentRegex.firstMatch(text);
      if (phonePeMatch != null) {
        merchant = _cleanMerchant(phonePeMatch.group(1)!);
      }
    }

    // Strategy C: Try VPA-based merchant (most reliable in bank SMS)
    if (merchant == null) {
      final vpaMatch = _vpaRegex.firstMatch(text);
      if (vpaMatch != null) {
        merchant = _cleanMerchant(vpaMatch.group(1)!);
      }
    }

    // Strategy D: Try standard "to/at <merchant>" pattern
    if (merchant == null) {
      final merchantMatch = _merchantRegex.firstMatch(text);
      if (merchantMatch != null) {
        merchant = _cleanMerchant(merchantMatch.group(1)!);
      }
    }

    // Strategy E: Try bank SMS pattern "to <name>" near UPI/A/c context
    if (merchant == null) {
      final bankMatch = _bankSmsMerchantRegex.firstMatch(text);
      if (bankMatch != null) {
        merchant = _cleanMerchant(bankMatch.group(1)!);
      }
    }

    // Strategy F: Try phone number as merchant (P2P transfers)
    if (merchant == null) {
      final phoneMatch = _phoneNumberRegex.firstMatch(text);
      if (phoneMatch != null) {
        merchant = _formatPhoneNumber(phoneMatch.group(1)!);
      }
    }

    // Strategy G: Try "from <merchant>" pattern
    if (merchant == null) {
      final fromMatch = _merchantFromRegex.firstMatch(text);
      if (fromMatch != null) {
        merchant = _cleanMerchant(fromMatch.group(1)!);
      }
    }

    // 4. Extract UPI reference
    String? upiRef;
    final refMatch = _upiRefRegex.firstMatch(text);
    if (refMatch != null) {
      upiRef = refMatch.group(1);
    }

    return ParsedTransaction(
      amount: amount,
      merchant: merchant,
      isDebit: isDebit,
      upiRef: upiRef,
      rawText: text,
      sourceApp: sourceApp,
    );
  }

  /// Clean up extracted merchant name
  static String _cleanMerchant(String raw) {
    var cleaned = raw.trim();

    // Remove trailing punctuation
    cleaned = cleaned.replaceAll(RegExp(r'[.,;:!?\s]+$'), '');

    // Remove "a/c", "account" suffixes
    cleaned = cleaned.replaceAll(RegExp(r'\s*(a/c|account|ac)\s*$', caseSensitive: false), '');

    // Remove "was successful", "successfully" etc.
    cleaned = cleaned.replaceAll(
      RegExp(r'\s*(was\s+)?successful(ly)?\s*$', caseSensitive: false), '');

    // Remove common noise words at the end
    cleaned = cleaned.replaceAll(
      RegExp(r'\s*(your|the|a)\s*$', caseSensitive: false), '');

    // Capitalize first letter of each word
    if (cleaned.isNotEmpty) {
      cleaned = cleaned.split(' ').map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
    }

    return cleaned.isEmpty ? 'Unknown' : cleaned;
  }

  /// Format a phone number for display as merchant name
  static String _formatPhoneNumber(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      // +91XXXXXXXXXX → +91 XXXXX XXXXX
      return '+91 ${digits.substring(2, 7)} ${digits.substring(7)}';
    } else if (digits.length == 10) {
      // XXXXXXXXXX → XXXXX XXXXX
      return '${digits.substring(0, 5)} ${digits.substring(5)}';
    }
    return raw;
  }
}
