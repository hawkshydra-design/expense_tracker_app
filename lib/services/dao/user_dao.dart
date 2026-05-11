import '../../models/user.dart';
import '../../repositories/user_repository.dart';
import '../database_service.dart';

/// SQLite-backed implementation of [UserRepository].
/// Focused on user table operations only.
class UserDao implements UserRepository {
  final DatabaseService _dbService;

  UserDao(this._dbService);

  /// Insert a new user
  @override
  Future<void> insertUser(User user) async {
    final db = await _dbService.database;
    await db.insert('users', user.toMap());
  }

  /// Find user by email
  @override
  Future<User?> findUserByEmail(String email) async {
    final db = await _dbService.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  /// Find user by ID
  @override
  Future<User?> findUserById(String id) async {
    final db = await _dbService.database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  /// Update user password
  @override
  Future<bool> updateUserPassword(
      String email, String hash, String salt) async {
    final db = await _dbService.database;
    final count = await db.update(
      'users',
      {'passwordHash': hash, 'salt': salt},
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );
    return count > 0;
  }
}
