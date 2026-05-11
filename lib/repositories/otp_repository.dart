import '../models/otp_record.dart';

/// Repository interface for OTP persistence.
/// Decouples OTP service from the concrete database implementation.
abstract class OtpRepository {
  /// Insert OTP record
  Future<void> insertOtp(OtpRecord record);

  /// Invalidate previous OTPs for an email
  Future<void> invalidateOtps(String email);

  /// Get latest unused OTP for an email
  Future<OtpRecord?> getLatestOtp(String email);

  /// Mark OTP as used
  Future<void> markOtpUsed(int id);

  /// Increment OTP attempt count
  Future<void> incrementOtpAttempts(int id, int currentAttempts);
}
