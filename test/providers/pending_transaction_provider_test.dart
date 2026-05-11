import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/providers/pending_transaction_provider.dart';
import 'package:expense_tracker/models/pending_transaction.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/repositories/pending_transaction_repository.dart';
import 'package:expense_tracker/repositories/expense_repository.dart';
import 'package:expense_tracker/services/event_bus.dart';


// ─── Mock Repositories ────────────────────────────────────────

class MockPendingRepo implements PendingTransactionRepository {
  final List<PendingTransaction> _store = [];
  bool shouldThrow = false;

  void seed(PendingTransaction tx) => _store.add(tx);

  @override
  Future<List<PendingTransaction>> getPendingTransactions(String userId) async {
    if (shouldThrow) throw Exception('DB error');
    return _store.where((t) => t.userId == userId && t.status == PendingStatus.pending).toList();
  }

  @override
  Future<void> insertPending(PendingTransaction transaction) async {
    if (shouldThrow) throw Exception('Insert failed');
    _store.add(transaction);
  }

  @override
  Future<void> confirmTransaction(String id) async {
    if (shouldThrow) throw Exception('Confirm failed');
    _store.removeWhere((t) => t.id == id);
  }

  @override
  Future<void> dismissTransaction(String id) async {
    if (shouldThrow) throw Exception('Dismiss failed');
    _store.removeWhere((t) => t.id == id);
  }

  @override
  Future<void> dismissAllForUser(String userId) async {
    if (shouldThrow) throw Exception('DismissAll failed');
    _store.removeWhere((t) => t.userId == userId);
  }

  @override
  Future<int> getPendingCount(String userId) async {
    return _store.where((t) => t.userId == userId && t.status == PendingStatus.pending).length;
  }

  @override
  Future<void> updatePendingTransaction(PendingTransaction transaction) async {
    if (shouldThrow) throw Exception('Update failed');
    final idx = _store.indexWhere((t) => t.id == transaction.id);
    if (idx != -1) _store[idx] = transaction;
  }

  @override
  Future<bool> isDuplicate({
    required String userId,
    required double amount,
    required String? merchant,
    required Duration window,
  }) async {
    return false;
  }
}

class MockExpenseRepo implements ExpenseRepository {
  final List<Expense> inserted = [];
  bool shouldThrow = false;

  @override
  Future<void> insertExpense(Expense expense) async {
    if (shouldThrow) throw Exception('Insert failed');
    inserted.add(expense);
  }

  @override
  Future<List<Expense>> getAllExpenses(String userId) async => [];
  @override
  Future<List<Expense>> getExpenses(String userId, {int limit = 50, int offset = 0}) async => [];
  @override
  Future<void> updateExpense(Expense expense) async {}
  @override
  Future<void> deleteExpense(String id, String userId) async {}
  @override
  Future<List<Expense>> getExpensesByDateRange(
      String userId, DateTime start, DateTime end) async => [];
  @override
  Future<double> getTotalSpending(
      String userId, DateTime start, DateTime end) async => 0;
  @override
  Future<double> getTotalIncome(
      String userId, DateTime start, DateTime end) async => 0;
  @override
  Future<int> getExpenseCount(String userId) async => 0;
}

// ─── Tests ────────────────────────────────────────────────────

void main() {
  late MockPendingRepo mockPendingRepo;
  late MockExpenseRepo mockExpenseRepo;
  late EventBus eventBus;
  late PendingTransactionProvider provider;

  PendingTransaction makeTx({String id = 'tx-1', String userId = 'user-1'}) {
    return PendingTransaction(
      id: id,
      userId: userId,
      amount: 250.0,
      merchant: 'Swiggy',
      detectedAt: DateTime(2026, 4, 20),
      rawNotification: 'Rs.250 paid to Swiggy',
    );
  }

  setUp(() {
    mockPendingRepo = MockPendingRepo();
    mockExpenseRepo = MockExpenseRepo();
    eventBus = EventBus();
    provider = PendingTransactionProvider(
      pendingRepo: mockPendingRepo,
      expenseRepo: mockExpenseRepo,
      eventBus: eventBus,
    );
  });

  tearDown(() {
    eventBus.dispose();
  });

  group('Loading', () {
    test('loadPending populates list from repo', () async {
      mockPendingRepo.seed(makeTx(id: 'a'));
      mockPendingRepo.seed(makeTx(id: 'b'));

      await provider.setUser('user-1');

      expect(provider.pendingTransactions, hasLength(2));
      expect(provider.hasPending, isTrue);
      expect(provider.pendingCount, 2);
    });

    test('loadPending returns Failure on error', () async {
      mockPendingRepo.shouldThrow = true;
      await provider.setUser('user-1');

      expect(provider.lastError, isNotNull);
      expect(provider.error, contains('Failed'));
    });
  });

  group('Confirm', () {
    test('confirmTransaction creates expense and removes pending', () async {
      mockPendingRepo.seed(makeTx(id: 'tx-1'));
      await provider.setUser('user-1');

      final result = await provider.confirmTransaction('tx-1');

      expect(result.isSuccess, isTrue);
      expect(provider.pendingTransactions, isEmpty);
      expect(mockExpenseRepo.inserted, hasLength(1));
      expect(mockExpenseRepo.inserted.first.title, contains('Swiggy'));
    });

    test('confirmTransaction fires ExpenseCreatedEvent', () async {
      mockPendingRepo.seed(makeTx(id: 'tx-1'));
      await provider.setUser('user-1');

      final events = <ExpenseCreatedEvent>[];
      eventBus.on<ExpenseCreatedEvent>().listen(events.add);

      await provider.confirmTransaction('tx-1');
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
    });

    test('confirmTransaction returns Failure for unknown id', () async {
      await provider.setUser('user-1');
      final result = await provider.confirmTransaction('nonexistent');
      expect(result.isFailure, isTrue);
    });

    test('confirmTransaction returns Failure on repo error', () async {
      mockPendingRepo.seed(makeTx(id: 'tx-1'));
      await provider.setUser('user-1');
      mockExpenseRepo.shouldThrow = true;

      final result = await provider.confirmTransaction('tx-1');
      expect(result.isFailure, isTrue);
      expect(provider.lastError, isNotNull);
    });
  });

  group('Dismiss', () {
    test('dismissTransaction removes from list', () async {
      mockPendingRepo.seed(makeTx(id: 'tx-1'));
      await provider.setUser('user-1');

      final result = await provider.dismissTransaction('tx-1');

      expect(result.isSuccess, isTrue);
      expect(provider.pendingTransactions, isEmpty);
    });

    test('dismissAll clears all pending transactions', () async {
      mockPendingRepo.seed(makeTx(id: 'a'));
      mockPendingRepo.seed(makeTx(id: 'b'));
      mockPendingRepo.seed(makeTx(id: 'c'));
      await provider.setUser('user-1');

      final result = await provider.dismissAll();

      expect(result.isSuccess, isTrue);
      expect(provider.pendingTransactions, isEmpty);
    });

    test('dismissAll returns Failure when userId is empty', () async {
      final result = await provider.dismissAll();
      expect(result.isFailure, isTrue);
    });
  });

  group('Edit & Confirm', () {
    test('editAndConfirm creates expense with edited values', () async {
      mockPendingRepo.seed(makeTx(id: 'tx-1'));
      await provider.setUser('user-1');

      final result = await provider.editAndConfirm(
        id: 'tx-1',
        title: 'Edited Title',
        amount: 500.0,
        category: ExpenseCategory.food,
        note: 'Custom note',
      );

      expect(result.isSuccess, isTrue);
      expect(mockExpenseRepo.inserted.first.title, 'Edited Title');
      expect(mockExpenseRepo.inserted.first.amount, 500.0);
    });
  });

  group('addDetected', () {
    test('addDetected inserts at front of list', () async {
      await provider.setUser('user-1');

      provider.addDetected(makeTx(id: 'new-1'));

      expect(provider.pendingTransactions.first.id, 'new-1');
    });
  });

  group('clear', () {
    test('clear resets all state', () async {
      mockPendingRepo.seed(makeTx());
      await provider.setUser('user-1');

      provider.clear();

      expect(provider.pendingTransactions, isEmpty);
      expect(provider.lastError, isNull);
    });
  });
}
