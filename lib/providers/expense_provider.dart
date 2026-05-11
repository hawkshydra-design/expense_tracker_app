import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/income_category.dart';
import '../repositories/expense_repository.dart';
import '../services/event_bus.dart';
import '../utils/result.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _expenseRepo;
  final EventBus _eventBus;
  final Uuid _uuid = const Uuid();
  StreamSubscription? _eventSub;

  ExpenseProvider({
    required ExpenseRepository expenseRepo,
    required EventBus eventBus,
  })  : _expenseRepo = expenseRepo,
        _eventBus = eventBus {
    // Subscribe to cross-provider events
    _eventSub = _eventBus.on<ExpenseCreatedEvent>().listen((event) {
      _addExternalExpense(event.expense);
    });
  }

  String _userId = '';
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  // ─── Cached aggregations ──────────────────────────────────
  double? _todayCache;
  double? _weekCache;
  double? _monthCache;
  Map<ExpenseCategory, double>? _categoryCache;

  // ─── Getters ────────────────────────────────────────────────

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get userId => _userId;

  /// Set the active user and load their expenses
  Future<void> setUser(String userId) async {
    _userId = userId;
    await loadExpenses();
  }

  /// Only expense-type transactions
  List<Expense> get onlyExpenses =>
      _expenses.where((e) => e.type == TransactionType.expense).toList();

  /// Only income-type transactions
  List<Expense> get onlyIncome =>
      _expenses.where((e) => e.type == TransactionType.income).toList();

  /// Total of all loaded expenses (expense type only)
  double get totalExpenses =>
      onlyExpenses.fold(0.0, (sum, e) => sum + e.amount);

  /// Total of all loaded income
  double get totalIncome =>
      onlyIncome.fold(0.0, (sum, e) => sum + e.amount);

  /// Net balance (income - expenses)
  double get netBalance => totalIncome - totalExpenses;

  /// Today's spending (cached)
  double get todaySpending {
    if (_todayCache != null) return _todayCache!;
    final now = DateTime.now();
    _todayCache = _expenses
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
    return _todayCache!;
  }

  /// This week's spending (cached)
  double get weekSpending {
    if (_weekCache != null) return _weekCache!;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    _weekCache = _expenses
        .where(
            (e) => e.date.isAfter(start.subtract(const Duration(seconds: 1))))
        .fold<double>(0.0, (sum, e) => sum + e.amount);
    return _weekCache!;
  }

  /// This month's spending (cached)
  double get monthSpending {
    if (_monthCache != null) return _monthCache!;
    final now = DateTime.now();
    _monthCache = _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
    return _monthCache!;
  }

  /// Previous month's spending (for comparison)
  double get previousMonthSpending {
    final now = DateTime.now();
    final prevMonth = DateTime(now.year, now.month - 1);
    return _expenses
        .where((e) =>
            e.date.year == prevMonth.year && e.date.month == prevMonth.month)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  /// Month-over-month spending difference
  double get monthTrend => monthSpending - previousMonthSpending;

  /// Spending grouped by category (cached)
  Map<ExpenseCategory, double> get spendingByCategory {
    if (_categoryCache != null) return _categoryCache!;
    final map = <ExpenseCategory, double>{};
    for (final expense in _expenses) {
      map[expense.category] = (map[expense.category] ?? 0) + expense.amount;
    }
    _categoryCache = map;
    return _categoryCache!;
  }

  /// Recent 5 expenses
  List<Expense> get recentExpenses {
    final sorted = List<Expense>.from(_expenses)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  /// Invalidate all caches — nuclear option for edits, deletes, and full reloads.
  void _invalidateCaches() {
    _todayCache = null;
    _weekCache = null;
    _monthCache = null;
    _categoryCache = null;
  }

  /// Targeted cache invalidation — only clears caches affected by [date].
  /// More efficient than _invalidateCaches() for single-item add operations.
  void _invalidateForDate(DateTime date) {
    final now = DateTime.now();
    _categoryCache = null; // always affected by any add

    // Only invalidate today cache if the new item is today
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      _todayCache = null;
    }

    // Only invalidate week cache if the item falls in the current week
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);
    if (!date.isBefore(startOfWeek)) {
      _weekCache = null;
    }

    // Only invalidate month cache if same month
    if (date.year == now.year && date.month == now.month) {
      _monthCache = null;
    }
  }

  // ─── CRUD Methods ──────────────────────────────────────────

  /// Load all expenses for the current user from database
  Future<Result<void>> loadExpenses() async {
    if (_userId.isEmpty) return const Failure(DataError.loadFailed);
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenses = await _expenseRepo.getAllExpenses(_userId);
      _invalidateCaches();
      _isLoading = false;
      notifyListeners();
      return const Success(null);
    } catch (e) {
      _error = DataError.loadFailed.message;
      _isLoading = false;
      notifyListeners();
      return Failure(
          DataError('Failed to load expenses', debugInfo: e.toString()));
    }
  }

  /// Add a new expense
  Future<Result<void>> addExpense({
    required String title,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    String? note,
  }) async {
    final expense = Expense(
      id: _uuid.v4(),
      userId: _userId,
      title: title,
      amount: amount,
      category: category,
      date: date,
      note: note,
    );

    try {
      await _expenseRepo.insertExpense(expense);
      _expenses.insert(0, expense);
      _invalidateForDate(date);
      notifyListeners();
      return const Success(null);
    } catch (e) {
      _error = DataError.saveFailed.message;
      notifyListeners();
      return Failure(
          DataError('Failed to add expense', debugInfo: e.toString()));
    }
  }

  /// Add a new income
  Future<Result<void>> addIncome({
    required String title,
    required double amount,
    required IncomeCategory incomeCategory,
    required DateTime date,
    String? note,
  }) async {
    final income = Expense(
      id: _uuid.v4(),
      userId: _userId,
      title: title,
      amount: amount,
      category: ExpenseCategory.other,
      date: date,
      note: note,
      type: TransactionType.income,
      incomeCategory: incomeCategory,
    );

    try {
      await _expenseRepo.insertExpense(income);
      _expenses.insert(0, income);
      _invalidateForDate(date);
      notifyListeners();
      return const Success(null);
    } catch (e) {
      _error = DataError.saveFailed.message;
      notifyListeners();
      return Failure(
          DataError('Failed to add income', debugInfo: e.toString()));
    }
  }

  /// Restore a previously deleted expense (for undo)
  Future<Result<void>> restoreExpense(Expense expense) async {
    try {
      await _expenseRepo.insertExpense(expense);
      _expenses.insert(0, expense);
      _invalidateCaches();
      notifyListeners();
      return const Success(null);
    } catch (e) {
      _error = DataError.saveFailed.message;
      notifyListeners();
      return Failure(
          DataError('Failed to restore expense', debugInfo: e.toString()));
    }
  }

  /// Update an existing expense
  Future<Result<void>> updateExpense(Expense expense) async {
    try {
      await _expenseRepo.updateExpense(expense);
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = expense;
        _invalidateCaches();
        notifyListeners();
      }
      return const Success(null);
    } catch (e) {
      _error = DataError.updateFailed.message;
      notifyListeners();
      return Failure(
          DataError('Failed to update expense', debugInfo: e.toString()));
    }
  }

  /// Delete an expense — returns the deleted expense for undo
  Future<Expense?> deleteExpense(String id) async {
    try {
      final expense = _expenses.firstWhere((e) => e.id == id);
      await _expenseRepo.deleteExpense(id, _userId);
      _expenses.removeWhere((e) => e.id == id);
      _invalidateCaches();
      notifyListeners();
      return expense;
    } catch (e) {
      _error = DataError.deleteFailed.message;
      notifyListeners();
      return null;
    }
  }

  /// Get expenses for a specific month
  List<Expense> getExpensesForMonth(int year, int month) {
    return _expenses
        .where((e) => e.date.year == year && e.date.month == month)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get expenses filtered by date range (from loaded data)
  List<Expense> getExpensesInRange(DateTime start, DateTime end) {
    return _expenses
        .where((e) =>
            !e.date.isBefore(start) &&
            !e.date.isAfter(end))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get total spending for a specific date range (from loaded data)
  double getSpendingInRange(DateTime start, DateTime end) {
    return getExpensesInRange(start, end)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Handle an expense created externally (via EventBus).
  /// Updates the in-memory cache without a full database reload.
  void _addExternalExpense(Expense expense) {
    // Avoid duplicates (e.g. if this provider also created it)
    if (_expenses.any((e) => e.id == expense.id)) return;
    _expenses.insert(0, expense);
    _invalidateForDate(expense.date);
    notifyListeners();
  }

  /// Clear all data (on logout)
  void clear() {
    _expenses = [];
    _userId = '';
    _invalidateCaches();
    notifyListeners();
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }
}
