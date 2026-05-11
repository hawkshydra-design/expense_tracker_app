import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/otp_record.dart';
import '../repositories/otp_repository.dart';
import 'email_service.dart';

/// OTP generation, storage, verification, and sending service.
/// Stores hashed OTPs in SQLite with 5-minute expiry.
/// Never returns raw OTP to callers — defense in depth.
class OtpService {
  final OtpRepository _otpRepo;
  final EmailService _emailService;

  OtpService(this._otpRepo, this._emailService);

  // Rate limiting: persisted to SharedPreferences to survive app restarts
  static const String _lastSentKeyPrefix = 'otp_last_sent_';
  static const int _cooldownSeconds = 60;
  static const int _otpExpiryMinutes = 5;

  /// Generate a random 6-digit OTP
  String _generateOTP() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Hash OTP for secure storage
  String _hashOTP(String otp) {
    return sha256.convert(utf8.encode(otp)).toString();
  }

  /// Generate OTP, store hashed, and send via email.
  /// Returns true if OTP was sent successfully, false if rate-limited or failed.
  Future<bool> sendOTP({
    required String email,
    String purpose = 'verification',
  }) async {
    // Persistent rate limiting check
    final prefs = await SharedPreferences.getInstance();
    final lastSentKey = '$_lastSentKeyPrefix${email.toLowerCase()}';
    final lastSentStr = prefs.getString(lastSentKey);
    if (lastSentStr != null) {
      final lastSent = DateTime.tryParse(lastSentStr);
      if (lastSent != null) {
        final secondsSinceLast = DateTime.now().difference(lastSent).inSeconds;
        if (secondsSinceLast < _cooldownSeconds) {
          return false; // Rate limited
        }
      }
    }

    // Invalidate any previous unused OTPs for this email
    await _otpRepo.invalidateOtps(email);

    // Generate new OTP
    final otp = _generateOTP();
    final hashedOtp = _hashOTP(otp);
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(minutes: _otpExpiryMinutes));

    // Store typed OTP record in database
    await _otpRepo.insertOtp(OtpRecord(
      id: 0, // Auto-incremented by SQLite
      email: email.toLowerCase(),
      otpHash: hashedOtp,
      expiresAt: expiresAt,
      createdAt: now,
    ));

    // Update persistent rate limit tracker
    await prefs.setString(lastSentKey, now.toIso8601String());

    // Send via email — OTP only goes to email, never returned to caller
    final sent = await _emailService.sendOTP(
      recipientEmail: email,
      otpCode: otp,
      purpose: purpose,
    );

    return sent;
  }

  /// Verify the user-entered OTP against the stored hash.
  /// Returns true if valid, false if invalid/expired/max attempts.
  Future<bool> verifyOTP({
    required String email,
    required String inputOTP,
  }) async {
    final record = await _otpRepo.getLatestOtp(email);
    if (record == null) return false;

    // Check expiry
    if (record.isExpired) {
      await _otpRepo.markOtpUsed(record.id);
      return false;
    }

    // Check max attempts
    if (record.isMaxAttempts) {
      await _otpRepo.markOtpUsed(record.id);
      return false;
    }

    // Verify hash
    final inputHash = _hashOTP(inputOTP);
    if (inputHash == record.otpHash) {
      // Mark as used
      await _otpRepo.markOtpUsed(record.id);
      return true;
    }

    // Wrong OTP — increment attempts
    await _otpRepo.incrementOtpAttempts(record.id, record.attempts);
    return false;
  }

  /// Get remaining cooldown seconds (0 if no cooldown).
  /// Now reads from persistent storage.
  Future<int> getCooldownRemaining(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final lastSentStr = prefs.getString('$_lastSentKeyPrefix${email.toLowerCase()}');
    if (lastSentStr == null) return 0;

    final lastSent = DateTime.tryParse(lastSentStr);
    if (lastSent == null) return 0;

    final elapsed = DateTime.now().difference(lastSent).inSeconds;
    final remaining = _cooldownSeconds - elapsed;
    return remaining > 0 ? remaining : 0;
  }
}
