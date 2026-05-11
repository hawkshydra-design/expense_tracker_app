import '../models/expense.dart';

/// Repository interface for expense persistence.
/// Decouples business logic from the concrete database implementation.
abstract class ExpenseRepository {
  /// Get all expenses for a user, ordered by date (newest first)
  Future<List<Expense>> getAllExpenses(String userId);

  /// Get a paginated list of expenses for a user
  Future<List<Expense>> getExpenses(String userId, {int limit = 50, int offset = 0});

  /// Insert a new expense
  Future<void> insertExpense(Expense expense);

  /// Update an existing expense
  Future<void> updateExpense(Expense expense);

  /// Delete an expense by ID (scoped to user)
  Future<void> deleteExpense(String id, String userId);

  /// Get expenses filtered by date range for a user
  Future<List<Expense>> getExpensesByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  );

  /// Get total spending (expenses only) for a user in a specific date range
  Future<double> getTotalSpending(String userId, DateTime start, DateTime end);

  /// Get total income for a user in a specific date range
  Future<double> getTotalIncome(String userId, DateTime start, DateTime end);

  /// Get total count of expenses for a user
  Future<int> getExpenseCount(String userId);
}
