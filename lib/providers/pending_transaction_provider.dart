import 'package:flutter/material.dart';
import '../models/pending_transaction.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../repositories/pending_transaction_repository.dart';
import '../repositories/expense_repository.dart';
import '../services/event_bus.dart';
import '../utils/result.dart';
import 'package:uuid/uuid.dart';

/// Provider for managing pending (auto-detected) transactions.
///
/// Bridges the gap between detected notifications and confirmed expenses.
/// Provides state for the dashboard banner and pending transactions screen.
///
/// Uses [Result<T>] for all fallible operations, consistent with
/// [ExpenseProvider]'s error-handling pattern.
class PendingTransactionProvider extends ChangeNotifier {
  final PendingTransactionRepository _pendingRepo;
  final ExpenseRepository _expenseRepo;
  final EventBus _eventBus;
  final Uuid _uuid = const Uuid();

  PendingTransactionProvider({
    required PendingTransactionRepository pendingRepo,
    required ExpenseRepository expenseRepo,
    required EventBus eventBus,
  })  : _pendingRepo = pendingRepo,
        _eventBus = eventBus,
        _expenseRepo = expenseRepo;

  List<PendingTransaction> _pendingTransactions = [];
  bool _isLoading = false;
  AppError? _lastError;
  String _userId = '';

  // ─── Getters ──────────────────────────────────────────────

  List<PendingTransaction> get pendingTransactions => _pendingTransactions;
  bool get isLoading => _isLoading;

  /// Typed error from the last failed operation, or null if the last op succeeded.
  AppError? get lastError => _lastError;

  /// Legacy getter — returns user-facing message string for backward compatibility.
  String? get error => _lastError?.message;

  int get pendingCount => _pendingTransactions.length;
  bool get hasPending => _pendingTransactions.isNotEmpty;

  /// The top 2 pending items for banner preview
  List<PendingTransaction> get previewItems =>
      _pendingTransactions.take(2).toList();

  // ─── Actions ──────────────────────────────────────────────

  /// Set active user and load pending transactions
  Future<void> setUser(String userId) async {
    _userId = userId;
    await loadPending();
  }

  /// Load all pending transactions from database
  Future<Result<List<PendingTransaction>>> loadPending() async {
    if (_userId.isEmpty) return const Success([]);

    _isLoading = true;
    notifyListeners();

    try {
      _pendingTransactions =
          await _pendingRepo.getPendingTransactions(_userId);
      _lastError = null;
      _isLoading = false;
      notifyListeners();
      return Success(_pendingTransactions);
    } catch (e) {
      _lastError = DataError('Failed to load pending transactions',
          debugInfo: e.toString());
      debugPrint('PendingTransactionProvider: Load failed: $e');
      _isLoading = false;
      notifyListeners();
      return Failure(_lastError!);
    }
  }

  /// Add a newly detected transaction (called by NotificationBridge)
  void addDetected(PendingTransaction transaction) {
    _pendingTransactions.insert(0, transaction);
    notifyListeners();
  }

  /// Confirm a pending transaction — converts it to a real expense.
  /// Returns [Success<Expense>] with the created expense, or [Failure].
  /// Notifies via [onExpenseCreated] to keep ExpenseProvider cache in sync.
  Future<Result<Expense>> confirmTransaction(String id) async {
    final index = _pendingTransactions.indexWhere((t) => t.id == id);
    if (index == -1) {
      return const Failure(
          DataError('Transaction not found', debugInfo: 'ID not in local list'));
    }

    final pending = _pendingTransactions[index];

    try {
      // 1. Create an expense from the pending transaction
      final expense = Expense(
        id: _uuid.v4(),
        userId: pending.userId,
        title: pending.displayTitle,
        amount: pending.amount,
        category: pending.expenseCategory,
        date: pending.detectedAt,
        note: 'Auto-detected from ${pending.sourceApp ?? "UPI"}',
      );

      // 2. Insert the expense
      await _expenseRepo.insertExpense(expense);

      // 3. Mark pending as confirmed
      await _pendingRepo.confirmTransaction(id);

      // 4. Remove from local list
      _pendingTransactions.removeAt(index);
      _lastError = null;
      notifyListeners();

      // 5. Notify listeners via event bus (ExpenseProvider subscribes)
      _eventBus.fire(ExpenseCreatedEvent(expense));

      return Success(expense);
    } catch (e) {
      _lastError = DataError('Failed to confirm transaction',
          debugInfo: e.toString());
      debugPrint('PendingTransactionProvider: Confirm failed: $e');
      notifyListeners();
      return Failure(_lastError!);
    }
  }

  /// Dismiss a pending transaction.
  /// Returns [Success] on success, [Failure] on error.
  Future<Result<void>> dismissTransaction(String id) async {
    final index = _pendingTransactions.indexWhere((t) => t.id == id);
    if (index == -1) {
      return const Failure(
          DataError('Transaction not found', debugInfo: 'ID not in local list'));
    }

    try {
      await _pendingRepo.dismissTransaction(id);
      _pendingTransactions.removeAt(index);
      _lastError = null;
      notifyListeners();
      return const Success(null);
    } catch (e) {
      _lastError = DataError('Failed to dismiss transaction',
          debugInfo: e.toString());
      debugPrint('PendingTransactionProvider: Dismiss failed: $e');
      notifyListeners();
      return Failure(_lastError!);
    }
  }

  /// Edit a pending transaction's details, then confirm it.
  /// Returns [Success<Expense>] with the created expense, or [Failure].
  /// Notifies via [onExpenseCreated] to keep ExpenseProvider cache in sync.
  Future<Result<Expense>> editAndConfirm({
    required String id,
    required String title,
    required double amount,
    required ExpenseCategory category,
    String? note,
  }) async {
    final index = _pendingTransactions.indexWhere((t) => t.id == id);
    if (index == -1) {
      return const Failure(
          DataError('Transaction not found', debugInfo: 'ID not in local list'));
    }

    final pending = _pendingTransactions[index];

    try {
      // Create expense with edited values
      final expense = Expense(
        id: _uuid.v4(),
        userId: pending.userId,
        title: title,
        amount: amount,
        category: category,
        date: pending.detectedAt,
        note: note ?? 'Auto-detected from ${pending.sourceApp ?? "UPI"}',
      );

      await _expenseRepo.insertExpense(expense);
      await _pendingRepo.confirmTransaction(id);

      _pendingTransactions.removeAt(index);
      _lastError = null;
      notifyListeners();

      // Notify listeners via event bus (ExpenseProvider subscribes)
      _eventBus.fire(ExpenseCreatedEvent(expense));

      return Success(expense);
    } catch (e) {
      _lastError = DataError('Failed to save transaction',
          debugInfo: e.toString());
      debugPrint('PendingTransactionProvider: EditAndConfirm failed: $e');
      notifyListeners();
      return Failure(_lastError!);
    }
  }

  /// Dismiss all pending transactions at once using a single batch query.
  Future<Result<void>> dismissAll() async {
    if (_userId.isEmpty) {
      return const Failure(
          DataError('No active user', debugInfo: 'userId is empty'));
    }

    try {
      await _pendingRepo.dismissAllForUser(_userId);
      _pendingTransactions.clear();
      _lastError = null;
      notifyListeners();
      return const Success(null);
    } catch (e) {
      _lastError = DataError('Failed to dismiss all',
          debugInfo: e.toString());
      debugPrint('PendingTransactionProvider: DismissAll failed: $e');
      notifyListeners();
      return Failure(_lastError!);
    }
  }

  /// Clear all data (on logout)
  void clear() {
    _pendingTransactions = [];
    _userId = '';
    _lastError = null;
    notifyListeners();
  }
}
