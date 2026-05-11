import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/services/auto_categorizer.dart';
import 'package:expense_tracker/models/category.dart';

void main() {
  group('AutoCategorizer', () {
    // ─── Food ────────────────────────────────────────────────
    group('food detection', () {
      test('categorizes Swiggy as food', () {
        expect(
          AutoCategorizer.categorize(
            merchant: 'Swiggy',
            rawText: '₹200 paid to Swiggy',
          ),
          ExpenseCategory.food,
        );
      });

      test('categorizes Zomato as food', () {
        expect(
          AutoCategorizer.categorize(
            merchant: 'Zomato',
            rawText: '₹300 paid to Zomato',
          ),
          ExpenseCategory.food,
        );
      });

      test('categorizes restaurant from raw text', () {
        expect(
          AutoCategorizer.categorize(
            merchant: null,
            rawText: 'Payment at the restaurant for dinner',
          ),
          ExpenseCategory.food,
        );
      });

      test('categorizes Blinkit as food (grocery)', () {
        expect(
          AutoCategorizer.categorize(
            merchant: 'Blinkit',
            rawText: '₹500 paid to Blinkit',
          ),
          ExpenseCategory.food,
        );
      });
    });

    // ─── Transport ───────────────────────────────────────────
    group('transport detection', () {
      test('categorizes Uber as transport', () {
        expect(
          AutoCategorizer.categorize(
            merchant: 'Uber',
            rawText: '₹150 paid to Uber',
          ),
          ExpenseCategory.transport,
        );
      });

      test('categorizes Ola as transport', () {
        expect(
          AutoCategorizer.categorize(
            merchant: 'Ola',
            rawText: '₹200 paid to Ola',
          ),
          ExpenseCategory.transport,
        );
      });

      test('categorizes IRCTC as transport', () {
        expect(
          AutoCategorizer.categorize(
            merchant: 'IRCTC',
            rawText: '₹1500 paid to IRCTC for train booking',
          ),
          ExpenseCategory.transport,
        );
      });

      test('categorizes petrol from raw text', () {
        expect(
          AutoCategorizer.categorize(
            merchant: null,
            rawText: 'Paid for petrol at HP fuel station',
          ),
          ExpenseCategory.transport,
        );
      });
    });

    // ─── Shopping ────────────────────────────────────────────
    group('shopping detection', () {
      test('categorizes Amazon as shopping', () {
        expect(
          AutoCategorizer.categorize(
            merchant: 'Amazon',
            rawText: '₹999 paid to Amazon',
          ),
          ExpenseCategory.shopping,
        );
      });

      test('categorizes Flipkart as shopping', () {
        expect(
          AutoCategorizer.categorize(
            merchant: 'Flipkart',
            rawText: '₹2000 paid to Flipkart',
          ),
          ExpenseCategory.shopping,
        );
      });

      test('categorizes Myntra as shopping', () {
        expect(
          AutoCategorizer.categorize(
            merchant: 'Myntra',
            rawText: '₹1200 paid to Myntra',
          ),
          ExpenseCategory.shopping,
        );
      });
    });

    // ─── Bills ───────────────────────────────────────────────
    group('bills detection', () {
      test('categorizes Airtel as bills', () {
        expect(
          AutoCategorizer.categorize(
            merchant: 'Airtel',
            rawText: '₹299 recharge to Airtel',
          ),
          ExpenseCategory.bills,
        );
      });

      test('recognizes electricity keyword', () {
        expect(
          AutoCategorizer.categorize(
            merchant: null,
            rawText: 'Electricity bill payment completed',
          ),
          ExpenseCategory.bills,
        );
      });

      test('recognizes rent keyword', () {
        expect(
          AutoCategorizer.categorize(
            merchant: null,
            rawText: 'Monthly rent payment to landlord',
          ),
          ExpenseCategory.bills,
        );
      });
    });

    // ─── Entertainment ───────────────────────────────────────
    group('entertainment detection', () {
      test('categorizes Netflix as entertainment', () {
        expect(
          AutoCategorizer.categorize(
            merchant: 'Netflix',
            rawText: '₹199 paid to Netflix',
          ),
          ExpenseCategory.entertainment,
        );
      });

      test('categorizes BookMyShow as entertainment', () {
        expect(
          AutoCategorizer.categorize(
            merchant: 'BookMyShow',
            rawText: '₹500 paid to BookMyShow for movie tickets',
          ),
          ExpenseCategory.entertainment,
        );
      });
    });

    // ─── Health ──────────────────────────────────────────────
    group('health detection', () {
      test('categorizes Apollo as health', () {
        expect(
          AutoCategorizer.categorize(
            merchant: 'Apollo Pharmacy',
            rawText: '₹350 paid to Apollo Pharmacy',
          ),
          ExpenseCategory.health,
        );
      });

      test('recognizes gym keyword', () {
        expect(
          AutoCategorizer.categorize(
            merchant: null,
            rawText: 'Payment for gym membership renewal',
          ),
          ExpenseCategory.health,
        );
      });
    });

    // ─── Education ───────────────────────────────────────────
    group('education detection', () {
      test('categorizes Udemy as education', () {
        expect(
          AutoCategorizer.categorize(
            merchant: 'Udemy',
            rawText: '₹449 paid to Udemy',
          ),
          ExpenseCategory.education,
        );
      });

      test('recognizes education keywords in clean text', () {
        expect(
          AutoCategorizer.categorize(
            merchant: null,
            rawText: 'Paid tuition fees for the semester',
          ),
          ExpenseCategory.education,
        );
      });
    });

    // ─── Fallback ────────────────────────────────────────────
    group('fallback to other', () {
      test('returns other for unknown merchant', () {
        expect(
          AutoCategorizer.categorize(
            merchant: 'JohnDoe',
            rawText: '₹100 paid to JohnDoe',
          ),
          ExpenseCategory.other,
        );
      });

      test('returns other for empty inputs', () {
        expect(
          AutoCategorizer.categorize(
            merchant: null,
            rawText: 'Some random transaction notification',
          ),
          ExpenseCategory.other,
        );
      });
    });

    // ─── Priority: merchant over raw text ────────────────────
    group('merchant priority', () {
      test('merchant match takes priority over raw text', () {
        // Merchant is "Swiggy" (food), but text mentions "movie" (entertainment)
        expect(
          AutoCategorizer.categorize(
            merchant: 'Swiggy',
            rawText: 'Paid for movie night snacks at restaurant via Swiggy',
          ),
          ExpenseCategory.food,
        );
      });
    });

    // ─── Case-insensitivity ──────────────────────────────────
    group('case insensitivity', () {
      test('matches uppercase merchant', () {
        expect(
          AutoCategorizer.categorize(
            merchant: 'NETFLIX',
            rawText: '₹199 paid to NETFLIX',
          ),
          ExpenseCategory.entertainment,
        );
      });

      test('matches mixed case raw text', () {
        expect(
          AutoCategorizer.categorize(
            merchant: null,
            rawText: 'Payment at UBER Moto for today ride',
          ),
          ExpenseCategory.transport,
        );
      });
    });
  });
}
