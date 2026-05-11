import 'package:equatable/equatable.dart';
import 'category.dart';
import 'income_category.dart';

/// The type of financial transaction.
enum TransactionType {
  expense,
  income;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionType.expense,
    );
  }
}

class Expense extends Equatable {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final TransactionType type;
  final IncomeCategory? incomeCategory;

  Expense({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    DateTime? createdAt,
    this.type = TransactionType.expense,
    this.incomeCategory,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert Expense to a Map for SQLite insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'category': category.name,
      'date': date.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'type': type.name,
      'incomeCategory': incomeCategory?.name,
    };
  }

  /// Create an Expense from a SQLite Map
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: ExpenseCategory.fromString(map['category'] as String),
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      type: TransactionType.fromString(map['type'] as String? ?? 'expense'),
      incomeCategory: map['incomeCategory'] != null
          ? IncomeCategory.fromString(map['incomeCategory'] as String)
          : null,
    );
  }

  /// Create a copy with optional field overrides
  Expense copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
    TransactionType? type,
    IncomeCategory? incomeCategory,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt,
      type: type ?? this.type,
      incomeCategory: incomeCategory ?? this.incomeCategory,
    );
  }

  /// Whether this is an income transaction
  bool get isIncome => type == TransactionType.income;

  /// Display category label (works for both income and expense)
  String get displayCategory => isIncome
      ? (incomeCategory?.label ?? 'Income')
      : category.label;

  @override
  List<Object?> get props =>
      [id, userId, title, amount, category, date, note, createdAt, type, incomeCategory];

  @override
  String toString() {
    return 'Expense(id: $id, title: $title, amount: $amount, '
        'category: ${category.label}, type: ${type.name}, date: $date)';
  }
}

