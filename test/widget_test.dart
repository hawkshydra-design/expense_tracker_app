import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/app.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());
    expect(find.text('Expense Tracker'), findsOneWidget);
  });
}
