import 'package:sqflite/sqflite.dart';
import '../../models/expense.dart';
import '../../repositories/expense_repository.dart';
import '../database_service.dart';

/// SQLite-backed implementation of [ExpenseRepository].
/// Focused on expense table operations only.
class ExpenseDao implements ExpenseRepository {
  final DatabaseService _dbService;

  ExpenseDao(this._dbService);

  /// Insert a new expense
  @override
  Future<void> insertExpense(Expense expense) async {
    final db = await _dbService.database;
    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing expense
  @override
  Future<void> updateExpense(Expense expense) async {
    final db = await _dbService.database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ? AND userId = ?',
      whereArgs: [expense.id, expense.userId],
    );
  }

  /// Delete an expense by ID (scoped to user)
  @override
  Future<void> deleteExpense(String id, String userId) async {
    final db = await _dbService.database;
    await db.delete(
      'expenses',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  /// Get all expenses for a user, ordered by date (newest first)
  @override
  Future<List<Expense>> getAllExpenses(String userId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'expenses',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, createdAt DESC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  /// Get a paginated list of expenses
  @override
  Future<List<Expense>> getExpenses(String userId, {int limit = 50, int offset = 0}) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'expenses',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, createdAt DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  /// Get expenses filtered by date range for a user
  @override
  Future<List<Expense>> getExpensesByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'expenses',
      where: 'userId = ? AND date BETWEEN ? AND ?',
      whereArgs: [userId, start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  /// Get total spending (expenses only) for a user in a specific date range
  @override
  Future<double> getTotalSpending(
      String userId, DateTime start, DateTime end) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE userId = ? AND type = ? AND date BETWEEN ? AND ?',
      [userId, 'expense', start.toIso8601String(), end.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get total income for a user in a specific date range
  @override
  Future<double> getTotalIncome(
      String userId, DateTime start, DateTime end) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE userId = ? AND type = ? AND date BETWEEN ? AND ?',
      [userId, 'income', start.toIso8601String(), end.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get total count of expenses for a user
  @override
  Future<int> getExpenseCount(String userId) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM expenses WHERE userId = ?',
      [userId],
    );
    return (result.first['count'] as int?) ?? 0;
  }
}
