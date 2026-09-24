/// Google-style password strength validation.
/// Checks length, uppercase, lowercase, digit, and special character requirements.
/// Zero dependencies.
class PasswordValidator {
  PasswordValidator._();

  static const _minLength = 8;

  /// Strict validation for signup — all rules enforced.
  /// Returns error message or null if valid.
  /// Shows ALL failing rules at once (Google-style).
  static String? validateStrict(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    // Common weak passwords — check first
    if (_weakPasswords.contains(value.toLowerCase())) {
      return 'This password is too common';
    }

    final errors = <String>[];

    if (value.length < _minLength) {
      errors.add('• Use $_minLength or more characters');
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      errors.add('• Add a lowercase letter (a-z)');
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      errors.add('• Add an uppercase letter (A-Z)');
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      errors.add('• Add a number (0-9)');
    }
    if (!RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"|,.<>?/\\`~]').hasMatch(value)) {
      errors.add('• Add a special character (!@#\$%^&*)');
    }

    if (errors.isEmpty) return null; // Strong ✅
    return errors.join('\n');
  }

  /// Light validation for login — just check non-empty.
  /// (Existing users may have old passwords that don't meet new rules.)
  static String? validateLogin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  /// Returns a strength label for UI display.
  static PasswordStrength getStrength(String value) {
    if (value.isEmpty) return PasswordStrength.none;

    int score = 0;
    if (value.length >= _minLength) score++;
    if (value.length >= 12) score++;
    if (RegExp(r'[a-z]').hasMatch(value)) score++;
    if (RegExp(r'[A-Z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"|,.<>?/\\`~]').hasMatch(value)) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.fair;
    if (score <= 5) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  static const _weakPasswords = <String>{
    'password', 'password1', 'password123', '12345678', '123456789',
    '1234567890', 'qwerty123', 'abc12345', 'iloveyou', 'admin123',
    'welcome1', 'monkey123', 'dragon123', 'master123', 'letmein1',
    'trustno1', 'baseball1', 'shadow123', 'michael1', 'football1',
    'password!', 'qwertyui', 'asdfghjk', 'zxcvbnm1', 'abcdefgh',
    'abcd1234', 'pass1234', 'test1234', 'hello123', 'changeme',
  };
}

/// Password strength levels for UI indicators.
enum PasswordStrength {
  none('', 0.0),
  weak('Weak', 0.25),
  fair('Fair', 0.50),
  strong('Strong', 0.75),
  veryStrong('Very Strong', 1.0);

  final String label;
  final double value;
  const PasswordStrength(this.label, this.value);
}
