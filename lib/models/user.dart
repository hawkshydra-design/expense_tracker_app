import 'package:equatable/equatable.dart';

/// User model — backed by Firebase Auth.
/// No longer stores credentials locally (Firebase handles hashing/sessions).
class User extends Equatable {
  final String id; // Firebase UID
  final String fullName;
  final String email;
  final String? photoUrl; // Google profile picture
  final DateTime createdAt;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    this.photoUrl,
    required this.createdAt,
  });

  User copyWith({
    String? fullName,
    String? email,
    String? photoUrl,
  }) {
    return User(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, fullName, email, photoUrl, createdAt];

  @override
  String toString() => 'User(id: $id, name: $fullName, email: $email)';
}
