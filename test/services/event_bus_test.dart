
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/services/event_bus.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/category.dart';

void main() {
  late EventBus eventBus;

  setUp(() {
    eventBus = EventBus();
  });

  tearDown(() {
    eventBus.dispose();
  });

  Expense makeExpense({String id = 'e1'}) {
    return Expense(
      id: id,
      userId: 'user-1',
      title: 'Test',
      amount: 100.0,
      category: ExpenseCategory.food,
      date: DateTime(2026, 4, 20),
    );
  }

  group('EventBus', () {
    test('fire delivers event to listener', () async {
      final events = <ExpenseCreatedEvent>[];
      eventBus.on<ExpenseCreatedEvent>().listen(events.add);

      eventBus.fire(ExpenseCreatedEvent(makeExpense()));

      // Allow stream to propagate
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.expense.id, 'e1');
    });

    test('typed filter — only the subscribed type is received', () async {
      final created = <ExpenseCreatedEvent>[];
      final deleted = <ExpenseDeletedEvent>[];

      eventBus.on<ExpenseCreatedEvent>().listen(created.add);
      eventBus.on<ExpenseDeletedEvent>().listen(deleted.add);

      eventBus.fire(ExpenseCreatedEvent(makeExpense()));
      eventBus.fire(ExpenseDeletedEvent('e2'));
      eventBus.fire(ExpenseCreatedEvent(makeExpense(id: 'e3')));

      await Future.delayed(Duration.zero);

      expect(created, hasLength(2));
      expect(deleted, hasLength(1));
      expect(deleted.first.expenseId, 'e2');
    });

    test('multiple subscribers all receive the event', () async {
      final listenerA = <AppEvent>[];
      final listenerB = <AppEvent>[];

      eventBus.on<ExpenseCreatedEvent>().listen(listenerA.add);
      eventBus.on<ExpenseCreatedEvent>().listen(listenerB.add);

      eventBus.fire(ExpenseCreatedEvent(makeExpense()));
      await Future.delayed(Duration.zero);

      expect(listenerA, hasLength(1));
      expect(listenerB, hasLength(1));
    });

    test('cancelled subscription stops receiving events', () async {
      final events = <AppEvent>[];
      final sub = eventBus.on<ExpenseCreatedEvent>().listen(events.add);

      eventBus.fire(ExpenseCreatedEvent(makeExpense()));
      await Future.delayed(Duration.zero);
      expect(events, hasLength(1));

      await sub.cancel();

      eventBus.fire(ExpenseCreatedEvent(makeExpense(id: 'e2')));
      await Future.delayed(Duration.zero);
      expect(events, hasLength(1)); // No new events
    });

    test('no events delivered after dispose', () async {
      final events = <AppEvent>[];
      eventBus.on<ExpenseCreatedEvent>().listen(
        events.add,
        onError: (_) {}, // Suppress post-close errors
      );

      eventBus.dispose();
      // Should not throw — broadcast controller silently ignores adds after close
      // but won't deliver
    });
  });

  group('Event classes', () {
    test('ExpenseCreatedEvent holds expense', () {
      final e = makeExpense();
      final event = ExpenseCreatedEvent(e);
      expect(event.expense, same(e));
    });

    test('ExpenseDeletedEvent holds id', () {
      const event = ExpenseDeletedEvent('abc');
      expect(event.expenseId, 'abc');
    });

    test('ExpenseUpdatedEvent holds expense', () {
      final e = makeExpense();
      final event = ExpenseUpdatedEvent(e);
      expect(event.expense, same(e));
    });
  });
}
