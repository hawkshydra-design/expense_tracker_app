import 'dart:async';
import '../models/expense.dart';

// ─── Event Types ──────────────────────────────────────────────

/// Base class for all app-level domain events.
sealed class AppEvent {
  const AppEvent();
}

/// Fired when a new expense is created (from any source).
class ExpenseCreatedEvent extends AppEvent {
  final Expense expense;
  const ExpenseCreatedEvent(this.expense);
}

/// Fired when an expense is deleted.
class ExpenseDeletedEvent extends AppEvent {
  final String expenseId;
  const ExpenseDeletedEvent(this.expenseId);
}

/// Fired when an expense is updated.
class ExpenseUpdatedEvent extends AppEvent {
  final Expense expense;
  const ExpenseUpdatedEvent(this.expense);
}

// ─── Event Bus ────────────────────────────────────────────────

/// Lightweight, zero-dependency event bus using a broadcast [StreamController].
///
/// Providers publish domain events here instead of holding direct references
/// to each other. Consumers subscribe to the typed stream they care about.
///
/// Usage:
/// ```dart
/// // Publishing
/// eventBus.fire(ExpenseCreatedEvent(expense));
///
/// // Subscribing
/// eventBus.on<ExpenseCreatedEvent>().listen((e) => ...);
/// ```
///
/// Registered as a singleton in [service_locator.dart].
class EventBus {
  final _controller = StreamController<AppEvent>.broadcast();

  /// Publish an event to all listeners.
  void fire(AppEvent event) => _controller.add(event);

  /// Listen to a specific event type.
  Stream<T> on<T extends AppEvent>() =>
      _controller.stream.where((e) => e is T).cast<T>();

  /// Dispose the internal stream — call on app shutdown if needed.
  void dispose() => _controller.close();
}
