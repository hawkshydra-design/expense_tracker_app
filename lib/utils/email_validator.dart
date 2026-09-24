/// Strict email validation with disposable domain blocking and typo detection.
/// Zero dependencies — uses built-in RegExp only.
class EmailValidator {
  EmailValidator._();

  /// Stricter RFC-compliant email regex.
  static final _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$",
  );

  /// Known disposable/temporary email domains.
  static const _disposableDomains = <String>{
    'mailinator.com', 'guerrillamail.com', 'guerrillamail.net',
    'tempmail.com', 'temp-mail.org', 'throwaway.email',
    'yopmail.com', 'yopmail.fr', 'sharklasers.com',
    'guerrillamailblock.com', 'grr.la', 'dispostable.com',
    'trashmail.com', 'trashmail.me', 'trashmail.net',
    'maildrop.cc', 'mailnesia.com', 'mailcatch.com',
    'fakeinbox.com', 'tempinbox.com', 'tempr.email',
    'discard.email', 'discardmail.com', 'discardmail.de',
    'getnada.com', 'harakirimail.com', 'mailforspam.com',
    'spamgourmet.com', 'mytemp.email', 'mohmal.com',
    'burnermail.io', 'inboxkitten.com', 'minutemail.com',
    'emailondeck.com', '10minutemail.com', 'tempail.com',
    'guerrillamail.de', 'crazymailing.com', 'tmail.ws',
    'wegwerfmail.de', 'trashymail.com', 'mailnator.com',
    'binkmail.com', 'bobmail.info', 'chammy.info',
    'devnullmail.com', 'letthemeatspam.com', 'mailexpire.com',
    'mailzilla.com', 'nomail.xl.cx', 'spam4.me',
    'spamfree24.org', 'spamhereplease.com', 'tempomail.fr',
    'trash-mail.at', 'uggsrock.com', 'mailsucker.net',
  };

  /// Common domain typos → correct domain.
  static const _typoCorrections = <String, String>{
    'gmial.com': 'gmail.com',
    'gmal.com': 'gmail.com',
    'gmaill.com': 'gmail.com',
    'gamil.com': 'gmail.com',
    'gnail.com': 'gmail.com',
    'gmail.con': 'gmail.com',
    'gmail.co': 'gmail.com',
    'gmail.cm': 'gmail.com',
    'gmaul.com': 'gmail.com',
    'gmali.com': 'gmail.com',
    'yahooo.com': 'yahoo.com',
    'yaho.com': 'yahoo.com',
    'yahoo.con': 'yahoo.com',
    'yaoo.com': 'yahoo.com',
    'yhaoo.com': 'yahoo.com',
    'hotmal.com': 'hotmail.com',
    'hotmial.com': 'hotmail.com',
    'hotmail.con': 'hotmail.com',
    'hotmaill.com': 'hotmail.com',
    'outlok.com': 'outlook.com',
    'outllok.com': 'outlook.com',
    'outlook.con': 'outlook.com',
    'outloo.com': 'outlook.com',
    'protonmal.com': 'protonmail.com',
    'protonmail.con': 'protonmail.com',
    'iclod.com': 'icloud.com',
    'icloudd.com': 'icloud.com',
    'icloud.con': 'icloud.com',
  };

  /// Minimum local part length (before @).
  static const _minLocalLength = 3;

  /// Validates email and returns error message or null if valid.
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final email = value.trim().toLowerCase();

    // Basic format check
    if (!_emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    final parts = email.split('@');
    if (parts.length != 2) return 'Enter a valid email address';

    final localPart = parts[0];
    final domain = parts[1];

    // Local part too short (likely fake)
    if (localPart.length < _minLocalLength) {
      return 'Email username is too short';
    }

    // Check for disposable/temporary email
    if (_disposableDomains.contains(domain)) {
      return 'Temporary emails are not allowed';
    }

    // Check for common typos and suggest correction
    final correction = _typoCorrections[domain];
    if (correction != null) {
      return 'Did you mean $localPart@$correction?';
    }

    // Check domain has valid TLD (not just single char)
    final domainParts = domain.split('.');
    if (domainParts.last.length < 2) {
      return 'Enter a valid email domain';
    }

    return null; // Valid
  }

  /// Returns true if email format is valid (no domain checks).
  static bool isValidFormat(String email) {
    return _emailRegex.hasMatch(email.trim().toLowerCase());
  }
}
