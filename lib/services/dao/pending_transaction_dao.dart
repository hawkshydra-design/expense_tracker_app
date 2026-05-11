import 'package:sqflite/sqflite.dart';
import '../../models/pending_transaction.dart';
import '../../repositories/pending_transaction_repository.dart';
import '../database_service.dart';

/// SQLite-backed implementation of [PendingTransactionRepository].
/// Focused on pending_transactions table operations only.
class PendingTransactionDao implements PendingTransactionRepository {
  final DatabaseService _dbService;

  PendingTransactionDao(this._dbService);

  /// Insert a new pending transaction
  @override
  Future<void> insertPending(PendingTransaction transaction) async {
    final db = await _dbService.database;
    await db.insert(
      'pending_transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all pending transactions for a user (status = 'pending')
  @override
  Future<List<PendingTransaction>> getPendingTransactions(String userId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'pending_transactions',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, 'pending'],
      orderBy: 'detected_at DESC',
    );
    return maps.map((map) => PendingTransaction.fromMap(map)).toList();
  }

  /// Get count of pending transactions
  @override
  Future<int> getPendingCount(String userId) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM pending_transactions WHERE user_id = ? AND status = ?',
      [userId, 'pending'],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Mark a transaction as confirmed
  @override
  Future<void> confirmTransaction(String id) async {
    final db = await _dbService.database;
    await db.update(
      'pending_transactions',
      {'status': 'confirmed'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Mark a transaction as dismissed
  @override
  Future<void> dismissTransaction(String id) async {
    final db = await _dbService.database;
    await db.update(
      'pending_transactions',
      {'status': 'dismissed'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Dismiss all pending transactions for a user in one operation
  @override
  Future<void> dismissAllForUser(String userId) async {
    final db = await _dbService.database;
    await db.update(
      'pending_transactions',
      {'status': 'dismissed'},
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, 'pending'],
    );
  }

  /// Update a pending transaction
  @override
  Future<void> updatePendingTransaction(PendingTransaction transaction) async {
    final db = await _dbService.database;
    await db.update(
      'pending_transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  /// Check for duplicate pending transaction within time window
  @override
  Future<bool> isDuplicate({
    required String userId,
    required double amount,
    required String? merchant,
    required Duration window,
  }) async {
    final db = await _dbService.database;
    final cutoff = DateTime.now().subtract(window).toIso8601String();

    String where;
    List<dynamic> args;

    if (merchant != null) {
      where = 'user_id = ? AND amount = ? AND merchant = ? AND detected_at > ? AND status = ?';
      args = [userId, amount, merchant, cutoff, 'pending'];
    } else {
      where = 'user_id = ? AND amount = ? AND merchant IS NULL AND detected_at > ? AND status = ?';
      args = [userId, amount, cutoff, 'pending'];
    }

    final result = await db.query(
      'pending_transactions',
      where: where,
      whereArgs: args,
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
