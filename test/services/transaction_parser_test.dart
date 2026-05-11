import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/services/transaction_parser.dart';

void main() {
  group('TransactionParser', () {
    // ─── Amount Extraction ─────────────────────────────────
    group('amount extraction', () {
      test('parses ₹ symbol amount', () {
        final result = TransactionParser.parse(
          text: 'You paid ₹500 to Swiggy',
          sourceApp: 'GPay',
        );
        expect(result, isNotNull);
        expect(result!.amount, 500.0);
      });

      test('parses Rs. amount with decimals', () {
        final result = TransactionParser.parse(
          text: 'Rs.1,200.50 debited from your account',
          sourceApp: 'SBI',
        );
        expect(result, isNotNull);
        expect(result!.amount, 1200.50);
      });

      test('parses INR amount', () {
        final result = TransactionParser.parse(
          text: 'INR 999 debited via UPI',
          sourceApp: 'PhonePe',
        );
        expect(result, isNotNull);
        expect(result!.amount, 999.0);
      });

      test('parses Rs amount without dot', () {
        final result = TransactionParser.parse(
          text: 'Rs 50 sent to seller',
          sourceApp: 'Paytm',
        );
        expect(result, isNotNull);
        expect(result!.amount, 50.0);
      });

      test('parses amount with commas', () {
        final result = TransactionParser.parse(
          text: '₹10,500 debited from account',
          sourceApp: 'HDFC',
        );
        expect(result, isNotNull);
        expect(result!.amount, 10500.0);
      });

      test('returns null for zero amount', () {
        final result = TransactionParser.parse(
          text: '₹0 debited from your account',
          sourceApp: 'SBI',
        );
        expect(result, isNull);
      });

      test('returns null for no amount', () {
        final result = TransactionParser.parse(
          text: 'Your UPI transaction is successful',
          sourceApp: 'GPay',
        );
        expect(result, isNull);
      });

      test('returns null for empty text', () {
        final result = TransactionParser.parse(
          text: '',
          sourceApp: 'GPay',
        );
        expect(result, isNull);
      });
    });

    // ─── Credit / Debit Detection ──────────────────────────
    group('debit-credit detection', () {
      test('skips credit-only transactions (income)', () {
        final result = TransactionParser.parse(
          text: '₹5000 credited to your account',
          sourceApp: 'SBI',
        );
        expect(result, isNull);
      });

      test('skips refund transactions', () {
        final result = TransactionParser.parse(
          text: 'Refund of ₹299 received from Amazon',
          sourceApp: 'HDFC',
        );
        expect(result, isNull);
      });

      test('skips cashback', () {
        final result = TransactionParser.parse(
          text: 'Cashback of ₹100 credited to wallet',
          sourceApp: 'GPay',
        );
        expect(result, isNull);
      });

      test('keeps debit transaction', () {
        final result = TransactionParser.parse(
          text: '₹300 debited from your account paid to Zomato',
          sourceApp: 'ICICI',
        );
        expect(result, isNotNull);
        expect(result!.amount, 300.0);
      });

      test('defaults to debit when no indicator', () {
        final result = TransactionParser.parse(
          text: '₹100 to Swiggy via UPI',
          sourceApp: 'GPay',
        );
        expect(result, isNotNull);
        expect(result!.isDebit, true);
      });
    });

    // ─── Merchant Extraction ───────────────────────────────
    group('merchant extraction', () {
      test('extracts "to <merchant>"', () {
        final result = TransactionParser.parse(
          text: '₹200 sent to Swiggy via UPI',
          sourceApp: 'GPay',
        );
        expect(result, isNotNull);
        expect(result!.merchant, 'Swiggy');
      });

      test('extracts "at <merchant>"', () {
        final result = TransactionParser.parse(
          text: '₹1500 spent at Amazon on 14 Apr',
          sourceApp: 'HDFC',
        );
        expect(result, isNotNull);
        expect(result!.merchant, 'Amazon');
      });

      test('extracts "paid to <merchant>"', () {
        final result = TransactionParser.parse(
          text: 'Rs.300 paid to Zomato via UPI',
          sourceApp: 'PhonePe',
        );
        expect(result, isNotNull);
        expect(result!.merchant, 'Zomato');
      });

      test('cleans merchant name trailing punctuation', () {
        final result = TransactionParser.parse(
          text: '₹500 paid to Swiggy. UPI Ref 123456',
          sourceApp: 'GPay',
        );
        expect(result, isNotNull);
        expect(result!.merchant, 'Swiggy');
      });

      test('returns null merchant when no pattern matches', () {
        final result = TransactionParser.parse(
          text: '₹100 debited successfully',
          sourceApp: 'SBI',
        );
        expect(result, isNotNull);
        expect(result!.merchant, isNull);
      });
    });

    // ─── UPI Reference Extraction ──────────────────────────
    group('UPI reference extraction', () {
      test('extracts UPI Ref No', () {
        final result = TransactionParser.parse(
          text: '₹500 paid to Swiggy. UPI Ref No. 412345678901',
          sourceApp: 'GPay',
        );
        expect(result, isNotNull);
        expect(result!.upiRef, '412345678901');
      });

      test('extracts UPI ref: format', () {
        final result = TransactionParser.parse(
          text: '₹300 debited. UPI ref: 987654321012',
          sourceApp: 'SBI',
        );
        expect(result, isNotNull);
        expect(result!.upiRef, '987654321012');
      });

      test('returns null ref when none found', () {
        final result = TransactionParser.parse(
          text: '₹200 paid to Amazon',
          sourceApp: 'GPay',
        );
        expect(result, isNotNull);
        expect(result!.upiRef, isNull);
      });
    });

    // ─── sourceApp is passed through ───────────────────────
    test('preserves sourceApp', () {
      final result = TransactionParser.parse(
        text: '₹100 paid to Swiggy',
        sourceApp: 'com.google.android.apps.nbu.paisa.user',
      );
      expect(result, isNotNull);
      expect(result!.sourceApp, 'com.google.android.apps.nbu.paisa.user');
    });

    // ─── Bank SMS Format Parsing ──────────────────────────
    group('bank SMS format', () {
      test('parses SBI debit SMS', () {
        final result = TransactionParser.parse(
          text: 'Your a/c XX1234 debited by Rs.500.00 on 20-Apr-25. '
              'UPI Ref No 412345678901. If not done by you, call 18001234567',
          sourceApp: 'com.miui.mms',
        );
        expect(result, isNotNull);
        expect(result!.amount, 500.0);
        expect(result!.isDebit, true);
        expect(result!.upiRef, '412345678901');
      });

      test('parses HDFC debit SMS with VPA', () {
        final result = TransactionParser.parse(
          text: 'INR 250.00 debited from A/c XXXX1234 on 20-04-25 '
              'to VPA merchant@upi (UPI Ref No. 412345678901)',
          sourceApp: 'com.samsung.android.messaging',
        );
        expect(result, isNotNull);
        expect(result!.amount, 250.0);
        expect(result!.merchant, 'Merchant');
      });

      test('parses bank SMS with Rs. format', () {
        final result = TransactionParser.parse(
          text: 'Rs.1500.00 debited from your A/c *1234 for UPI txn. '
              'UPI Ref: 412345678901. Balance: Rs.12345.67',
          sourceApp: 'com.vivo.mms',
        );
        expect(result, isNotNull);
        expect(result!.amount, 1500.0);
        expect(result!.upiRef, '412345678901');
      });

      test('parses Axis Bank SMS', () {
        final result = TransactionParser.parse(
          text: 'Rs 800 debited from A/c no XX1234 on 20-Apr towards '
              'SWIGGY. UPI Ref 312345678',
          sourceApp: 'com.oneplus.mms',
        );
        expect(result, isNotNull);
        expect(result!.amount, 800.0);
      });

      test('parses ICICI Bank SMS with merchant name', () {
        final result = TransactionParser.parse(
          text: 'Your ICICI Bank Acct XX1234 is debited with INR 1,299.00 '
              'on 20-Apr-25. UPI Ref no 412345678901',
          sourceApp: 'com.google.android.apps.messaging',
        );
        expect(result, isNotNull);
        expect(result!.amount, 1299.0);
        expect(result!.isDebit, true);
      });

      test('skips bank credit SMS', () {
        final result = TransactionParser.parse(
          text: 'Your a/c XX1234 credited with Rs.5000.00 on 20-Apr-25. '
              'IMPS Ref No 412345678901',
          sourceApp: 'com.miui.mms',
        );
        expect(result, isNull);
      });

      test('parses VPA-based merchant from SMS', () {
        final result = TransactionParser.parse(
          text: 'Rs.150 debited from a/c XX1234 to VPA swiggy@paytm. '
              'UPI Ref 412345678901',
          sourceApp: 'com.realme.mms',
        );
        expect(result, isNotNull);
        expect(result!.amount, 150.0);
        expect(result!.merchant, 'Swiggy');
      });
    });
  });
}
