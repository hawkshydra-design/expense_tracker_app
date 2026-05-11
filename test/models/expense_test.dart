import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/category.dart';

void main() {
  group('Expense model', () {
    final now = DateTime(2026, 4, 14, 10, 30);

    test('creates from constructor with defaults', () {
      final expense = Expense(
        id: 'test-1',
        userId: 'user-1',
        title: 'Lunch',
        amount: 200.0,
        category: ExpenseCategory.food,
        date: now,
      );

      expect(expense.id, 'test-1');
      expect(expense.note, isNull);
      expect(expense.type, TransactionType.expense); // default
    });

    test('round-trips through toMap/fromMap', () {
      final original = Expense(
        id: 'test-2',
        userId: 'user-1',
        title: 'Metro card',
        amount: 500.0,
        category: ExpenseCategory.transport,
        date: now,
        note: 'Monthly recharge',
        type: TransactionType.expense,
      );

      final map = original.toMap();
      final restored = Expense.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.title, original.title);
      expect(restored.amount, original.amount);
      expect(restored.category, original.category);
      expect(restored.note, original.note);
    });

    test('Equatable: equal when same props', () {
      final a = Expense(
        id: 'x', userId: 'u', title: 'T',
        amount: 100, category: ExpenseCategory.food, date: now,
      );
      final b = Expense(
        id: 'x', userId: 'u', title: 'T',
        amount: 100, category: ExpenseCategory.food, date: now,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('Equatable: not equal when different id', () {
      final a = Expense(
        id: 'x', userId: 'u', title: 'T',
        amount: 100, category: ExpenseCategory.food, date: now,
      );
      final b = Expense(
        id: 'y', userId: 'u', title: 'T',
        amount: 100, category: ExpenseCategory.food, date: now,
      );
      expect(a, isNot(equals(b)));
    });

    test('fromMap handles missing transactionType gracefully', () {
      final map = {
        'id': 'test-3',
        'userId': 'user-1',
        'title': 'Old expense',
        'amount': 50.0,
        'category': 'food',
        'date': now.toIso8601String(),
        'createdAt': now.toIso8601String(),
        // No transactionType key — simulates pre-migration data
      };

      final expense = Expense.fromMap(map);
      expect(expense.type, TransactionType.expense); // backward-compatible default
    });
  });

  group('TransactionType enum', () {
    test('values are correct', () {
      expect(TransactionType.values.length, 2);
      expect(TransactionType.expense.name, 'expense');
      expect(TransactionType.income.name, 'income');
    });
  });

  group('ExpenseCategory enhanced enum', () {
    test('has correct number of values', () {
      expect(ExpenseCategory.values.length, 8);
    });

    test('fromString returns correct category', () {
      expect(ExpenseCategory.fromString('food'), ExpenseCategory.food);
      expect(ExpenseCategory.fromString('transport'), ExpenseCategory.transport);
      expect(ExpenseCategory.fromString('unknown'), ExpenseCategory.other);
      expect(ExpenseCategory.fromString('unknown'), ExpenseCategory.other);
    });

    test('each category has label, icon, colorHex', () {
      for (final cat in ExpenseCategory.values) {
        expect(cat.label, isNotEmpty);
        expect(cat.icon, isNotNull);
        expect(cat.color, isNotNull);
      }
    });
  });
}
