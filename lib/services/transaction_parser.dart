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
class TransactionParser {
  TransactionParser._();

  // ─── Amount patterns ───────────────────────────────────────
  // Matches: ₹500, Rs.1,200.50, INR 999, Rs 50
  static final _amountRegex = RegExp(
    r'(?:Rs\.?\s?|₹\s?|INR\s?)([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  // ─── Debit indicators ─────────────────────────────────────
  static final _debitRegex = RegExp(
    r'(?:debited|debit|sent|paid|spent|purchase|payment|transferred|withdrawn|charged)',
    caseSensitive: false,
  );

  // ─── Credit indicators ────────────────────────────────────
  static final _creditRegex = RegExp(
    r'(?:credited|credit|received|refund|cashback|reversed|deposited)',
    caseSensitive: false,
  );

  // ─── Merchant extraction ──────────────────────────────────
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
    final isDebit = true;

    // 3. Extract merchant name
    String? merchant;

    // Try VPA-based merchant first (most reliable in bank SMS)
    final vpaMatch = _vpaRegex.firstMatch(text);
    if (vpaMatch != null) {
      merchant = _cleanMerchant(vpaMatch.group(1)!);
    }

    // Try standard "to/at <merchant>" pattern
    if (merchant == null) {
      final merchantMatch = _merchantRegex.firstMatch(text);
      if (merchantMatch != null) {
        merchant = _cleanMerchant(merchantMatch.group(1)!);
      }
    }

    // Try bank SMS pattern "to <name>" near UPI/A/c context
    if (merchant == null) {
      final bankMatch = _bankSmsMerchantRegex.firstMatch(text);
      if (bankMatch != null) {
        merchant = _cleanMerchant(bankMatch.group(1)!);
      }
    }

    // Try "from <merchant>" pattern
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

    // Capitalize first letter of each word
    if (cleaned.isNotEmpty) {
      cleaned = cleaned.split(' ').map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
    }

    return cleaned.isEmpty ? 'Unknown' : cleaned;
  }
}
