import 'package:equatable/equatable.dart';

/// Typed model for OTP records, replacing raw `Map<String, dynamic>`.
class OtpRecord extends Equatable {
  final int id;
  final String email;
  final String otpHash;
  final DateTime expiresAt;
  final bool isUsed;
  final int attempts;
  final DateTime createdAt;

  const OtpRecord({
    required this.id,
    required this.email,
    required this.otpHash,
    required this.expiresAt,
    this.isUsed = false,
    this.attempts = 0,
    required this.createdAt,
  });

  /// Create from SQLite map
  factory OtpRecord.fromMap(Map<String, dynamic> map) {
    return OtpRecord(
      id: map['id'] as int,
      email: map['email'] as String,
      otpHash: map['otpHash'] as String,
      expiresAt: DateTime.parse(map['expiresAt'] as String),
      isUsed: (map['isUsed'] as int) == 1,
      attempts: map['attempts'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Convert to SQLite map (without id — auto-incremented)
  Map<String, dynamic> toInsertMap() {
    return {
      'email': email,
      'otpHash': otpHash,
      'expiresAt': expiresAt.toIso8601String(),
      'isUsed': isUsed ? 1 : 0,
      'attempts': attempts,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Whether this OTP has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Whether max attempts have been reached
  bool get isMaxAttempts => attempts >= 3;

  @override
  List<Object?> get props =>
      [id, email, otpHash, expiresAt, isUsed, attempts, createdAt];

  @override
  String toString() => 'OtpRecord(id: $id, email: $email, '
      'used: $isUsed, attempts: $attempts)';
}
