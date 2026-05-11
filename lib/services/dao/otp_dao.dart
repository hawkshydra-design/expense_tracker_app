import '../../models/otp_record.dart';
import '../../repositories/otp_repository.dart';
import '../database_service.dart';

/// SQLite-backed implementation of [OtpRepository].
/// Focused on otp_codes table operations only.
class OtpDao implements OtpRepository {
  final DatabaseService _dbService;

  OtpDao(this._dbService);

  /// Insert OTP record
  @override
  Future<void> insertOtp(OtpRecord record) async {
    final db = await _dbService.database;
    await db.insert('otp_codes', record.toInsertMap());
  }

  /// Invalidate previous OTPs for an email
  @override
  Future<void> invalidateOtps(String email) async {
    final db = await _dbService.database;
    await db.update(
      'otp_codes',
      {'isUsed': 1},
      where: 'email = ? AND isUsed = 0',
      whereArgs: [email.toLowerCase()],
    );
  }

  /// Get latest unused OTP for an email
  @override
  Future<OtpRecord?> getLatestOtp(String email) async {
    final db = await _dbService.database;
    final results = await db.query(
      'otp_codes',
      where: 'email = ? AND isUsed = 0',
      whereArgs: [email.toLowerCase()],
      orderBy: 'createdAt DESC',
      limit: 1,
    );
    if (results.isEmpty) return null;
    return OtpRecord.fromMap(results.first);
  }

  /// Mark OTP as used
  @override
  Future<void> markOtpUsed(int id) async {
    final db = await _dbService.database;
    await db
        .update('otp_codes', {'isUsed': 1}, where: 'id = ?', whereArgs: [id]);
  }

  /// Increment OTP attempt count
  @override
  Future<void> incrementOtpAttempts(int id, int currentAttempts) async {
    final db = await _dbService.database;
    await db.update(
      'otp_codes',
      {'attempts': currentAttempts + 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
