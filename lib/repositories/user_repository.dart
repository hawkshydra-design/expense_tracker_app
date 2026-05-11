import '../models/user.dart';

/// Repository interface for user persistence.
/// Decouples business logic from the concrete database implementation.
abstract class UserRepository {
  /// Insert a new user record
  Future<void> insertUser(User user);

  /// Find user by email (returns typed User or null)
  Future<User?> findUserByEmail(String email);

  /// Find user by ID (returns typed User or null)
  Future<User?> findUserById(String id);

  /// Update user password hash and salt
  Future<bool> updateUserPassword(String email, String hash, String salt);
}
