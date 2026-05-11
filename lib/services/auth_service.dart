import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

/// Authentication service with salted password hashing.
/// Receives UserRepository via constructor injection.
///
/// NOTE: Uses a custom iterated SHA-256 scheme for password hashing.
/// This is NOT standard PBKDF2 — it is a simplified approximation suitable
/// for a local SQLite database. For production server-side auth, use
/// a proper KDF like bcrypt, scrypt, or Argon2.
class AuthService {
  final UserRepository _userRepo;
  static const int _hashIterations = 10000;

  AuthService(this._userRepo);

  /// Generate a cryptographically secure random salt
  String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List.generate(32, (_) => random.nextInt(256));
    return base64.encode(saltBytes);
  }

  /// Hash password with salt using iterated SHA-256.
  /// See class-level doc for security limitations.
  String _hashPassword(String password, String salt) {
    final key = utf8.encode(password + salt);
    var hash = sha256.convert(key);
    for (int i = 0; i < _hashIterations; i++) {
      hash = sha256.convert([...hash.bytes, ...utf8.encode(salt)]);
    }
    return hash.toString();
  }

  /// Register a new user
  Future<User?> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    // Check if email already exists
    final existing = await _userRepo.findUserByEmail(email);
    if (existing != null) return null;

    final salt = _generateSalt();
    final user = User(
      id: const Uuid().v4(),
      fullName: fullName.trim(),
      email: email.toLowerCase().trim(),
      passwordHash: _hashPassword(password, salt),
      salt: salt,
      createdAt: DateTime.now(),
    );

    await _userRepo.insertUser(user);
    return user;
  }

  /// Login with email and password
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final user = await _userRepo.findUserByEmail(email);
    if (user == null) return null;

    final hash = _hashPassword(password, user.salt);

    if (hash != user.passwordHash) return null;
    return user;
  }

  /// Find user by ID (for session restore)
  Future<User?> findUserById(String id) async {
    return await _userRepo.findUserById(id);
  }

  /// Find user by email (for forgot password)
  Future<User?> findUserByEmail(String email) async {
    return await _userRepo.findUserByEmail(email);
  }

  /// Update password hash (for password reset)
  Future<bool> updatePassword({
    required String email,
    required String newPassword,
  }) async {
    final salt = _generateSalt();
    final hash = _hashPassword(newPassword, salt);
    return await _userRepo.updateUserPassword(email, hash, salt);
  }
}
