import 'package:equatable/equatable.dart';

/// User model — typed replacement for raw `Map<String, dynamic>`
class User extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String passwordHash;
  final String salt;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.passwordHash,
    required this.salt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'passwordHash': passwordHash,
      'salt': salt,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      email: map['email'] as String,
      passwordHash: map['passwordHash'] as String,
      salt: (map['salt'] as String?) ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  User copyWith({
    String? fullName,
    String? email,
    String? passwordHash,
    String? salt,
  }) {
    return User(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, fullName, email, passwordHash, salt, createdAt];

  @override
  String toString() => 'User(id: $id, name: $fullName, email: $email)';
}
