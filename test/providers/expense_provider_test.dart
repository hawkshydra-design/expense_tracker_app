import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/models/income_category.dart';
import 'package:expense_tracker/repositories/expense_repository.dart';
import 'package:expense_tracker/services/event_bus.dart';


// ─── Mock Repository ──────────────────────────────────────────

class MockExpenseRepository implements ExpenseRepository {
  final List<Expense> _store = [];
  int insertCount = 0;
  int deleteCount = 0;
  int updateCount = 0;
  bool shouldThrow = false;

  @override
  Future<List<Expense>> getAllExpenses(String userId) async {
    if (shouldThrow) throw Exception('DB error');
    return _store.where((e) => e.userId == userId).toList();
  }

  @override
  Future<List<Expense>> getExpenses(String userId, {int limit = 50, int offset = 0}) async {
    if (shouldThrow) throw Exception('DB error');
    final all = _store.where((e) => e.userId == userId).toList();
    return all.skip(offset).take(limit).toList();
  }

  @override
  Future<void> insertExpense(Expense expense) async {
    if (shouldThrow) throw Exception('Insert failed');
    insertCount++;
    _store.add(expense);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    if (shouldThrow) throw Exception('Update failed');
    updateCount++;
    final idx = _store.indexWhere((e) => e.id == expense.id);
    if (idx != -1) _store[idx] = expense;
  }

  @override
  Future<void> deleteExpense(String id, String userId) async {
    if (shouldThrow) throw Exception('Delete failed');
    deleteCount++;
    _store.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<Expense>> getExpensesByDateRange(
      String userId, DateTime start, DateTime end) async {
    return _store
        .where((e) =>
            e.userId == userId &&
            !e.date.isBefore(start) &&
            !e.date.isAfter(end))
        .toList();
  }

  @override
  Future<double> getTotalSpending(
      String userId, DateTime start, DateTime end) async {
    final expenses = await getExpensesByDateRange(userId, start, end);
    return expenses
        .where((e) => e.type == TransactionType.expense)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Future<double> getTotalIncome(
      String userId, DateTime start, DateTime end) async {
    final expenses = await getExpensesByDateRange(userId, start, end);
    return expenses
        .where((e) => e.type == TransactionType.income)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Future<int> getExpenseCount(String userId) async {
    return _store.where((e) => e.userId == userId).length;
  }
}

// ─── Tests ────────────────────────────────────────────────────

void main() {
  late MockExpenseRepository mockRepo;
  late EventBus eventBus;
  late ExpenseProvider provider;

  setUp(() {
    mockRepo = MockExpenseRepository();
    eventBus = EventBus();
    provider = ExpenseProvider(
      expenseRepo: mockRepo,
      eventBus: eventBus,
    );
  });

  tearDown(() {
    provider.dispose();
    eventBus.dispose();
  });

  Expense makeExpense({
    String id = 'e1',
    String userId = 'user-1',
    double amount = 100.0,
    DateTime? date,
    TransactionType type = TransactionType.expense,
  }) {
    return Expense(
      id: id,
      userId: userId,
      title: 'Test',
      amount: amount,
      category: ExpenseCategory.food,
      date: date ?? DateTime.now(),
      type: type,
    );
  }

  group('CRUD operations', () {
    test('loadExpenses returns success and populates list', () async {
      // Seed mock data
      await mockRepo.insertExpense(
          makeExpense(id: 'e1', userId: 'user-1'));
      await mockRepo.insertExpense(
          makeExpense(id: 'e2', userId: 'user-1'));

      await provider.setUser('user-1');

      expect(provider.expenses, hasLength(2));
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('loadExpenses fails gracefully when userId is empty', () async {
      final result = await provider.loadExpenses();
      expect(result.isFailure, isTrue);
    });

    test('addExpense inserts into repo and updates list', () async {
      await provider.setUser('user-1');

      final result = await provider.addExpense(
        title: 'Coffee',
        amount: 50.0,
        category: ExpenseCategory.food,
        date: DateTime.now(),
      );

      expect(result.isSuccess, isTrue);
      expect(provider.expenses, hasLength(1));
      expect(provider.expenses.first.title, 'Coffee');
      expect(mockRepo.insertCount, 1);
    });

    test('addIncome inserts income transaction', () async {
      await provider.setUser('user-1');

      final result = await provider.addIncome(
        title: 'Salary',
        amount: 50000.0,
        incomeCategory: IncomeCategory.salary,
        date: DateTime.now(),
      );

      expect(result.isSuccess, isTrue);
      expect(provider.expenses.first.type, TransactionType.income);
      expect(provider.totalIncome, 50000.0);
    });

    test('deleteExpense removes from list and returns deleted item', () async {
      await provider.setUser('user-1');
      await provider.addExpense(
        title: 'Delete me',
        amount: 25.0,
        category: ExpenseCategory.other,
        date: DateTime.now(),
      );
      final id = provider.expenses.first.id;

      final deleted = await provider.deleteExpense(id);

      expect(deleted, isNotNull);
      expect(deleted!.title, 'Delete me');
      expect(provider.expenses, isEmpty);
    });

    test('updateExpense updates in-memory list', () async {
      await provider.setUser('user-1');
      await provider.addExpense(
        title: 'Original',
        amount: 100.0,
        category: ExpenseCategory.food,
        date: DateTime.now(),
      );
      final original = provider.expenses.first;

      final updated = Expense(
        id: original.id,
        userId: original.userId,
        title: 'Updated',
        amount: 200.0,
        category: ExpenseCategory.shopping,
        date: original.date,
      );

      final result = await provider.updateExpense(updated);

      expect(result.isSuccess, isTrue);
      expect(provider.expenses.first.title, 'Updated');
      expect(provider.expenses.first.amount, 200.0);
    });

    test('restoreExpense re-inserts a deleted expense', () async {
      await provider.setUser('user-1');
      await provider.addExpense(
        title: 'Restore me',
        amount: 75.0,
        category: ExpenseCategory.bills,
        date: DateTime.now(),
      );
      final expense = provider.expenses.first;
      await provider.deleteExpense(expense.id);
      expect(provider.expenses, isEmpty);

      final result = await provider.restoreExpense(expense);

      expect(result.isSuccess, isTrue);
      expect(provider.expenses, hasLength(1));
    });
  });

  group('Error handling', () {
    test('loadExpenses returns Failure on DB error', () async {
      mockRepo.shouldThrow = true;
      await provider.setUser('user-1');

      // setUser calls loadExpenses internally, which would have failed
      expect(provider.error, isNotNull);
    });

    test('addExpense returns Failure on insert error', () async {
      await provider.setUser('user-1');
      mockRepo.shouldThrow = true;

      final result = await provider.addExpense(
        title: 'Fail',
        amount: 10.0,
        category: ExpenseCategory.food,
        date: DateTime.now(),
      );

      expect(result.isFailure, isTrue);
    });
  });

  group('Aggregation & caching', () {
    test('totalExpenses sums only expense-type transactions', () async {
      await provider.setUser('user-1');

      await provider.addExpense(
        title: 'Expense 1',
        amount: 100.0,
        category: ExpenseCategory.food,
        date: DateTime.now(),
      );
      await provider.addIncome(
        title: 'Salary',
        amount: 50000.0,
        incomeCategory: IncomeCategory.salary,
        date: DateTime.now(),
      );

      expect(provider.totalExpenses, 100.0);
      expect(provider.totalIncome, 50000.0);
      expect(provider.netBalance, 50000.0 - 100.0);
    });

    test('spendingByCategory groups correctly', () async {
      await provider.setUser('user-1');

      await provider.addExpense(
        title: 'Food 1', amount: 100, category: ExpenseCategory.food,
        date: DateTime.now(),
      );
      await provider.addExpense(
        title: 'Food 2', amount: 200, category: ExpenseCategory.food,
        date: DateTime.now(),
      );
      await provider.addExpense(
        title: 'Transport', amount: 50, category: ExpenseCategory.transport,
        date: DateTime.now(),
      );

      final byCategory = provider.spendingByCategory;
      expect(byCategory[ExpenseCategory.food], 300.0);
      expect(byCategory[ExpenseCategory.transport], 50.0);
    });

    test('clear resets all state', () async {
      await provider.setUser('user-1');
      await provider.addExpense(
        title: 'Test', amount: 100, category: ExpenseCategory.food,
        date: DateTime.now(),
      );

      provider.clear();

      expect(provider.expenses, isEmpty);
      expect(provider.userId, isEmpty);
      expect(provider.totalExpenses, 0.0);
    });
  });

  group('Event bus integration', () {
    test('ExpenseCreatedEvent adds expense to in-memory list', () async {
      await provider.setUser('user-1');

      final external = makeExpense(id: 'ext-1', userId: 'user-1');
      eventBus.fire(ExpenseCreatedEvent(external));

      // Allow stream to propagate
      await Future.delayed(Duration.zero);

      expect(provider.expenses.any((e) => e.id == 'ext-1'), isTrue);
    });

    test('duplicate ExpenseCreatedEvent is ignored', () async {
      await provider.setUser('user-1');

      final external = makeExpense(id: 'dup-1', userId: 'user-1');
      eventBus.fire(ExpenseCreatedEvent(external));
      await Future.delayed(Duration.zero);

      // Fire again with same ID
      eventBus.fire(ExpenseCreatedEvent(external));
      await Future.delayed(Duration.zero);

      final matches =
          provider.expenses.where((e) => e.id == 'dup-1').length;
      expect(matches, 1); // No duplicate
    });
  });
}
