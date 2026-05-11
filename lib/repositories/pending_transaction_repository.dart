import '../models/pending_transaction.dart';

/// Repository interface for pending (auto-detected) transactions.
/// Decouples business logic from the concrete database implementation.
abstract class PendingTransactionRepository {
  /// Insert a new pending transaction
  Future<void> insertPending(PendingTransaction transaction);

  /// Get all pending transactions for a user (status = 'pending')
  Future<List<PendingTransaction>> getPendingTransactions(String userId);

  /// Get count of pending transactions for badge display
  Future<int> getPendingCount(String userId);

  /// Mark a transaction as confirmed
  Future<void> confirmTransaction(String id);

  /// Mark a transaction as dismissed
  Future<void> dismissTransaction(String id);

  /// Dismiss all pending transactions for a user in one operation
  Future<void> dismissAllForUser(String userId);

  /// Update a pending transaction (edit before confirming)
  Future<void> updatePendingTransaction(PendingTransaction transaction);

  /// Check if a similar transaction exists (for deduplication)
  /// Returns true if same amount within the time window
  Future<bool> isDuplicate({
    required String userId,
    required double amount,
    required String? merchant,
    required Duration window,
  });
}
