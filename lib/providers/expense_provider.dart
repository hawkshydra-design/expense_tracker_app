import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/income_category.dart';
import '../repositories/expense_repository.dart';
import '../services/event_bus.dart';
import '../utils/result.dart';

/// Typedef for backward compatibility — use TransactionProvider in new code.
typedef ExpenseProvider = TransactionProvider;

class TransactionProvider extends ChangeNotifier {
  final ExpenseRepository _expenseRepo;
  final EventBus _eventBus;
  final Uuid _uuid = const Uuid();
  StreamSubscription? _eventSub;

  TransactionProvider({
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
  double? _todayIncomeCache;
  double? _weekIncomeCache;
  double? _monthIncomeCache;
  Map<IncomeCategory, double>? _incomeCategoryCache;

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

  /// Today's spending — expense type only (cached)
  double get todaySpending {
    if (_todayCache != null) return _todayCache!;
    final now = DateTime.now();
    _todayCache = onlyExpenses
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
    return _todayCache!;
  }

  /// This week's spending — expense type only (cached)
  double get weekSpending {
    if (_weekCache != null) return _weekCache!;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    _weekCache = onlyExpenses
        .where(
            (e) => e.date.isAfter(start.subtract(const Duration(seconds: 1))))
        .fold<double>(0.0, (sum, e) => sum + e.amount);
    return _weekCache!;
  }

  /// This month's spending — expense type only (cached)
  double get monthSpending {
    if (_monthCache != null) return _monthCache!;
    final now = DateTime.now();
    _monthCache = onlyExpenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
    return _monthCache!;
  }

  /// Previous month's spending — expense type only (for comparison).
  double get previousMonthSpending {
    final now = DateTime.now();
    final prevMonth = DateTime(now.year, now.month - 1);
    return onlyExpenses
        .where((e) =>
            e.date.year == prevMonth.year && e.date.month == prevMonth.month)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  /// Month-over-month spending difference
  double get monthTrend => monthSpending - previousMonthSpending;

  /// Spending grouped by expense category (cached)
  Map<ExpenseCategory, double> get spendingByCategory {
    if (_categoryCache != null) return _categoryCache!;
    final map = <ExpenseCategory, double>{};
    for (final expense in onlyExpenses) {
      map[expense.category] = (map[expense.category] ?? 0) + expense.amount;
    }
    _categoryCache = map;
    return _categoryCache!;
  }

  // ─── Income Getters ─────────────────────────────────────────

  /// Today's income (cached)
  double get todayIncome {
    if (_todayIncomeCache != null) return _todayIncomeCache!;
    final now = DateTime.now();
    _todayIncomeCache = onlyIncome
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
    return _todayIncomeCache!;
  }

  /// This week's income (cached)
  double get weekIncome {
    if (_weekIncomeCache != null) return _weekIncomeCache!;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    _weekIncomeCache = onlyIncome
        .where(
            (e) => e.date.isAfter(start.subtract(const Duration(seconds: 1))))
        .fold<double>(0.0, (sum, e) => sum + e.amount);
    return _weekIncomeCache!;
  }

  /// This month's income (cached)
  double get monthIncome {
    if (_monthIncomeCache != null) return _monthIncomeCache!;
    final now = DateTime.now();
    _monthIncomeCache = onlyIncome
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
    return _monthIncomeCache!;
  }

  /// Income grouped by income category (cached)
  Map<IncomeCategory, double> get incomeByCategory {
    if (_incomeCategoryCache != null) return _incomeCategoryCache!;
    final map = <IncomeCategory, double>{};
    for (final income in onlyIncome) {
      final cat = income.incomeCategory ?? IncomeCategory.other;
      map[cat] = (map[cat] ?? 0) + income.amount;
    }
    _incomeCategoryCache = map;
    return _incomeCategoryCache!;
  }

  // ─── Bar Chart Data ─────────────────────────────────────────

  /// Last 7 days spending (for daily bar chart)
  /// Returns a map of day label → amount
  Map<String, double> get dailySpendingData {
    final now = DateTime.now();
    final map = <String, double>{};
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final label = dayNames[day.weekday - 1];
      map[label] = onlyExpenses
          .where((e) =>
              e.date.year == day.year &&
              e.date.month == day.month &&
              e.date.day == day.day)
          .fold<double>(0.0, (sum, e) => sum + e.amount);
    }
    return map;
  }

  /// Last 7 days income (for daily bar chart)
  Map<String, double> get dailyIncomeData {
    final now = DateTime.now();
    final map = <String, double>{};
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final label = dayNames[day.weekday - 1];
      map[label] = onlyIncome
          .where((e) =>
              e.date.year == day.year &&
              e.date.month == day.month &&
              e.date.day == day.day)
          .fold<double>(0.0, (sum, e) => sum + e.amount);
    }
    return map;
  }

  /// Last 4 weeks spending (for weekly bar chart)
  Map<String, double> get weeklySpendingData {
    final now = DateTime.now();
    final map = <String, double>{};
    for (int i = 3; i >= 0; i--) {
      final weekEnd = now.subtract(Duration(days: i * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 6));
      final label = 'W${4 - i}';
      map[label] = onlyExpenses
          .where((e) =>
              !e.date.isBefore(DateTime(weekStart.year, weekStart.month, weekStart.day)) &&
              !e.date.isAfter(DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59)))
          .fold<double>(0.0, (sum, e) => sum + e.amount);
    }
    return map;
  }

  /// Last 4 weeks income (for weekly bar chart)
  Map<String, double> get weeklyIncomeData {
    final now = DateTime.now();
    final map = <String, double>{};
    for (int i = 3; i >= 0; i--) {
      final weekEnd = now.subtract(Duration(days: i * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 6));
      final label = 'W${4 - i}';
      map[label] = onlyIncome
          .where((e) =>
              !e.date.isBefore(DateTime(weekStart.year, weekStart.month, weekStart.day)) &&
              !e.date.isAfter(DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59)))
          .fold<double>(0.0, (sum, e) => sum + e.amount);
    }
    return map;
  }

  /// Last 6 months spending (for monthly bar chart)
  Map<String, double> get monthlySpendingData {
    final now = DateTime.now();
    final map = <String, double>{};
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final label = monthNames[month.month - 1];
      map[label] = onlyExpenses
          .where((e) => e.date.year == month.year && e.date.month == month.month)
          .fold<double>(0.0, (sum, e) => sum + e.amount);
    }
    return map;
  }

  /// Last 6 months income (for monthly bar chart)
  Map<String, double> get monthlyIncomeData {
    final now = DateTime.now();
    final map = <String, double>{};
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final label = monthNames[month.month - 1];
      map[label] = onlyIncome
          .where((e) => e.date.year == month.year && e.date.month == month.month)
          .fold<double>(0.0, (sum, e) => sum + e.amount);
    }
    return map;
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
    _todayIncomeCache = null;
    _weekIncomeCache = null;
    _monthIncomeCache = null;
    _incomeCategoryCache = null;
  }

  /// Targeted cache invalidation — only clears caches affected by [date].
  /// More efficient than _invalidateCaches() for single-item add operations.
  void _invalidateForDate(DateTime date) {
    final now = DateTime.now();
    _categoryCache = null; // always affected by any add
    _incomeCategoryCache = null;

    // Only invalidate today cache if the new item is today
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      _todayCache = null;
      _todayIncomeCache = null;
    }

    // Only invalidate week cache if the item falls in the current week
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);
    if (!date.isBefore(startOfWeek)) {
      _weekCache = null;
      _weekIncomeCache = null;
    }

    // Only invalidate month cache if same month
    if (date.year == now.year && date.month == now.month) {
      _monthCache = null;
      _monthIncomeCache = null;
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
    // Input validation (#10, #11)
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty || trimmedTitle.length > 200) {
      return const Failure(DataError('Title must be 1-200 characters'));
    }
    if (amount <= 0 || amount > 999999999) {
      return const Failure(DataError('Amount must be between 0 and 999,999,999'));
    }
    if (note != null && note.length > 1000) {
      return const Failure(DataError('Note must be under 1000 characters'));
    }

    final expense = Expense(
      id: _uuid.v4(),
      userId: _userId,
      title: trimmedTitle,
      amount: amount,
      category: category,
      date: date,
      note: note?.trim(),
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
    // Input validation (#10, #11)
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty || trimmedTitle.length > 200) {
      return const Failure(DataError('Title must be 1-200 characters'));
    }
    if (amount <= 0 || amount > 999999999) {
      return const Failure(DataError('Amount must be between 0 and 999,999,999'));
    }
    if (note != null && note.length > 1000) {
      return const Failure(DataError('Note must be under 1000 characters'));
    }

    final income = Expense(
      id: _uuid.v4(),
      userId: _userId,
      title: trimmedTitle,
      amount: amount,
      category: ExpenseCategory.other,
      date: date,
      note: note?.trim(),
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
      // Use indexWhere + safe access instead of firstWhere to avoid
      // StateError if the expense was already removed (race condition fix #15)
      final index = _expenses.indexWhere((e) => e.id == id);
      if (index == -1) return null;
      final expense = _expenses[index];
      await _expenseRepo.deleteExpense(id, _userId);
      _expenses.removeAt(index);
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

  /// Get total spending (expenses only) for a specific date range
  double getSpendingInRange(DateTime start, DateTime end) {
    return getExpensesInRange(start, end)
        .where((e) => e.type == TransactionType.expense)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Get total income for a specific date range
  double getIncomeInRange(DateTime start, DateTime end) {
    return getExpensesInRange(start, end)
        .where((e) => e.type == TransactionType.income)
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
