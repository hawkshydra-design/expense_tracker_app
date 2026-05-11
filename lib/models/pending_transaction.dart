import 'package:equatable/equatable.dart';
import 'category.dart';

/// Status of a detected pending transaction.
enum PendingStatus {
  pending,
  confirmed,
  dismissed;

  static PendingStatus fromString(String value) {
    return PendingStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PendingStatus.pending,
    );
  }
}

/// A transaction detected from a UPI/bank notification.
/// Starts as [pending] and moves to [confirmed] (becomes an Expense)
/// or [dismissed] (ignored by user).
class PendingTransaction extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final String? merchant;
  final String category;
  final String? rawNotification;
  final String? sourceApp;
  final DateTime detectedAt;
  final PendingStatus status;

  const PendingTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    this.merchant,
    this.category = 'other',
    this.rawNotification,
    this.sourceApp,
    required this.detectedAt,
    this.status = PendingStatus.pending,
  });

  /// Convert to SQLite map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'merchant': merchant,
      'category': category,
      'raw_notification': rawNotification,
      'source_app': sourceApp,
      'detected_at': detectedAt.toIso8601String(),
      'status': status.name,
    };
  }

  /// Create from SQLite map
  factory PendingTransaction.fromMap(Map<String, dynamic> map) {
    return PendingTransaction(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      merchant: map['merchant'] as String?,
      category: map['category'] as String? ?? 'other',
      rawNotification: map['raw_notification'] as String?,
      sourceApp: map['source_app'] as String?,
      detectedAt: DateTime.parse(map['detected_at'] as String),
      status: PendingStatus.fromString(map['status'] as String? ?? 'pending'),
    );
  }

  /// Get the ExpenseCategory enum value
  ExpenseCategory get expenseCategory =>
      ExpenseCategory.fromString(category);

  /// Display name for the transaction
  String get displayTitle => merchant ?? 'UPI Payment';

  /// Create a copy with optional overrides
  PendingTransaction copyWith({
    String? id,
    String? userId,
    double? amount,
    String? merchant,
    String? category,
    String? rawNotification,
    String? sourceApp,
    DateTime? detectedAt,
    PendingStatus? status,
  }) {
    return PendingTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      merchant: merchant ?? this.merchant,
      category: category ?? this.category,
      rawNotification: rawNotification ?? this.rawNotification,
      sourceApp: sourceApp ?? this.sourceApp,
      detectedAt: detectedAt ?? this.detectedAt,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id, userId, amount, merchant, category,
        rawNotification, sourceApp, detectedAt, status,
      ];

  @override
  String toString() {
    return 'PendingTransaction(id: $id, amount: $amount, '
        'merchant: $merchant, category: $category, status: ${status.name})';
  }
}
