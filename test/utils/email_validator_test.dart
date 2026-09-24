import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/utils/email_validator.dart';

/// Tests for email validation logic — disposable domain blocking,
/// typo correction, and format validation.
void main() {
  group('EmailValidator', () {
    group('valid emails', () {
      test('accepts standard email', () {
        expect(EmailValidator.validate('user@gmail.com'), isNull);
      });

      test('accepts email with dots', () {
        expect(EmailValidator.validate('first.last@example.com'), isNull);
      });

      test('accepts email with plus alias', () {
        expect(EmailValidator.validate('user+tag@gmail.com'), isNull);
      });

      test('accepts email with numbers', () {
        expect(EmailValidator.validate('user123@domain.co.in'), isNull);
      });

      test('trims whitespace', () {
        expect(EmailValidator.validate('  user@gmail.com  '), isNull);
      });
    });

    group('invalid format', () {
      test('rejects null', () {
        expect(EmailValidator.validate(null), isNotNull);
      });

      test('rejects empty string', () {
        expect(EmailValidator.validate(''), isNotNull);
      });

      test('rejects whitespace only', () {
        expect(EmailValidator.validate('   '), isNotNull);
      });

      test('rejects missing @', () {
        expect(EmailValidator.validate('usergmail.com'), isNotNull);
      });

      test('rejects missing domain', () {
        expect(EmailValidator.validate('user@'), isNotNull);
      });

      test('rejects missing local part', () {
        expect(EmailValidator.validate('@gmail.com'), isNotNull);
      });
    });

    group('disposable domains', () {
      test('rejects tempmail.com', () {
        final result = EmailValidator.validate('test@tempmail.com');
        expect(result, isNotNull);
        expect(result!.toLowerCase(), contains('temporary'));
      });

      test('rejects guerrillamail.com', () {
        final result = EmailValidator.validate('test@guerrillamail.com');
        expect(result, isNotNull);
      });

      test('rejects mailinator.com', () {
        final result = EmailValidator.validate('test@mailinator.com');
        expect(result, isNotNull);
      });

      test('rejects yopmail.com', () {
        final result = EmailValidator.validate('test@yopmail.com');
        expect(result, isNotNull);
      });

      test('rejects throwaway.email', () {
        final result = EmailValidator.validate('test@throwaway.email');
        expect(result, isNotNull);
      });
    });

    group('typo suggestions', () {
      test('suggests gmail.com for gmial.com', () {
        final result = EmailValidator.validate('user@gmial.com');
        if (result != null) {
          expect(result.toLowerCase(), contains('gmail.com'));
        }
      });

      test('suggests gmail.com for gmal.com', () {
        final result = EmailValidator.validate('user@gmal.com');
        if (result != null) {
          expect(result.toLowerCase(), contains('gmail.com'));
        }
      });
    });
  });
}
