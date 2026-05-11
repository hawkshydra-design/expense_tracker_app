import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/otp_service.dart';
import '../services/session_service.dart';
import '../utils/result.dart';

/// Pending auth credentials stored in memory during OTP verification.
/// Never persisted or passed through navigation state.
class _PendingAuth {
  final String email;
  final String password;
  final String purpose;
  final String? fullName;

  const _PendingAuth({
    required this.email,
    required this.password,
    required this.purpose,
    this.fullName,
  });
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final OtpService _otpService;
  final SessionService _sessionService;

  AuthProvider({
    required AuthService authService,
    required OtpService otpService,
    required SessionService sessionService,
  })  : _authService = authService,
        _otpService = otpService,
        _sessionService = sessionService;

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;
  User? _currentUser;
  _PendingAuth? _pendingAuth;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;
  User? get currentUser => _currentUser;
  String get userName => _currentUser?.fullName ?? 'User';
  String get userEmail => _currentUser?.email ?? '';
  String get userId => _currentUser?.id ?? '';

  /// The email for the pending OTP flow (safe to display in UI)
  String? get pendingEmail => _pendingAuth?.email;

  /// The purpose for the pending OTP flow
  String? get pendingPurpose => _pendingAuth?.purpose;

  /// Try to auto-login from saved session
  Future<bool> tryAutoLogin() async {
    try {
      final session = await _sessionService.getSession();
      if (session == null) return false;

      // Verify user still exists in database
      final user = await _authService.findUserById(session['id']!);
      if (user == null) {
        await _sessionService.clearSession();
        return false;
      }

      _currentUser = user;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      await _sessionService.clearSession();
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════
  // OTP FLOW — All auth + OTP logic centralized here
  // ════════════════════════════════════════════════════════════

  /// Step 1: Validate login credentials and send OTP for 2FA.
  /// Returns a Result — screens should NOT call getIt directly.
  Future<Result<void>> initiateLogin({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate credentials first
      final user = await _authService.login(email: email, password: password);
      if (user == null) {
        _isLoading = false;
        _error = AuthError.invalidCredentials.message;
        notifyListeners();
        return const Failure(AuthError.invalidCredentials);
      }

      // Credentials valid — send OTP
      final sent = await _otpService.sendOTP(email: email, purpose: 'login');
      if (!sent) {
        _isLoading = false;
        _error = OtpError.sendFailed.message;
        notifyListeners();
        return const Failure(OtpError.sendFailed);
      }

      // Store credentials in memory — NOT in navigation state
      _pendingAuth = _PendingAuth(
        email: email,
        password: password,
        purpose: 'login',
      );

      _isLoading = false;
      notifyListeners();
      return const Success(null);
    } catch (e) {
      _isLoading = false;
      _error = 'Login failed: $e';
      notifyListeners();
      return Failure(AuthError('Login failed', debugInfo: e.toString()));
    }
  }

  /// Step 1: Validate signup fields and send OTP for verification.
  Future<Result<void>> initiateSignup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if email already exists
      final existing = await _authService.findUserByEmail(email);
      if (existing != null) {
        _isLoading = false;
        _error = AuthError.emailTaken.message;
        notifyListeners();
        return const Failure(AuthError.emailTaken);
      }

      // Send OTP for email verification
      final sent =
          await _otpService.sendOTP(email: email, purpose: 'verification');
      if (!sent) {
        _isLoading = false;
        _error = OtpError.sendFailed.message;
        notifyListeners();
        return const Failure(OtpError.sendFailed);
      }

      // Store pending credentials in memory
      _pendingAuth = _PendingAuth(
        email: email,
        password: password,
        purpose: 'signup',
        fullName: fullName,
      );

      _isLoading = false;
      notifyListeners();
      return const Success(null);
    } catch (e) {
      _isLoading = false;
      _error = 'Signup failed: $e';
      notifyListeners();
      return Failure(AuthError('Signup failed', debugInfo: e.toString()));
    }
  }

  /// Step 1: Validate email exists and send reset OTP.
  Future<Result<void>> initiateForgotPassword({
    required String email,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.findUserByEmail(email);
      if (user == null) {
        _isLoading = false;
        _error = AuthError.userNotFound.message;
        notifyListeners();
        return const Failure(AuthError.userNotFound);
      }

      final sent = await _otpService.sendOTP(email: email, purpose: 'reset');
      if (!sent) {
        _isLoading = false;
        _error = OtpError.sendFailed.message;
        notifyListeners();
        return const Failure(OtpError.sendFailed);
      }

      // Store pending auth for reset flow
      _pendingAuth = _PendingAuth(
        email: email,
        password: '', // No password for reset flow
        purpose: 'reset',
      );

      _isLoading = false;
      notifyListeners();
      return const Success(null);
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to initiate reset: $e';
      notifyListeners();
      return Failure(AuthError('Reset failed', debugInfo: e.toString()));
    }
  }

  /// Step 2: Verify OTP code. On success, performs the pending action
  /// (register, login, or navigate to reset password).
  /// Returns the purpose string so the screen knows what to do next.
  Future<Result<String>> verifyOtp({required String code}) async {
    if (_pendingAuth == null) {
      return const Failure(OtpError('No pending verification'));
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final isValid = await _otpService.verifyOTP(
        email: _pendingAuth!.email,
        inputOTP: code,
      );

      if (!isValid) {
        _isLoading = false;
        _error = OtpError.invalidCode.message;
        notifyListeners();
        return const Failure(OtpError.invalidCode);
      }

      final purpose = _pendingAuth!.purpose;

      // OTP verified — complete the action
      if (purpose == 'signup') {
        final success = await _completeRegistration();
        if (!success) {
          _isLoading = false;
          notifyListeners();
          return Failure(AuthError(_error ?? 'Registration failed'));
        }
      } else if (purpose == 'login') {
        final success = await _completeLogin();
        if (!success) {
          _isLoading = false;
          notifyListeners();
          return Failure(AuthError(_error ?? 'Login failed'));
        }
      }
      // For 'reset', we just mark OTP as valid — screen navigates to reset form

      _isLoading = false;
      notifyListeners();
      return Success(purpose);
    } catch (e) {
      _isLoading = false;
      _error = 'Verification failed: $e';
      notifyListeners();
      return Failure(OtpError('Verification failed', debugInfo: e.toString()));
    }
  }

  /// Resend OTP for the current pending flow
  Future<Result<void>> resendOtp() async {
    if (_pendingAuth == null) {
      return const Failure(OtpError('No pending verification'));
    }

    try {
      final sent = await _otpService.sendOTP(
        email: _pendingAuth!.email,
        purpose: _pendingAuth!.purpose,
      );

      if (!sent) {
        return const Failure(OtpError.rateLimited);
      }

      return const Success(null);
    } catch (e) {
      return Failure(OtpError('Resend failed', debugInfo: e.toString()));
    }
  }

  /// Complete registration after OTP verification
  Future<bool> _completeRegistration() async {
    final pending = _pendingAuth!;
    final user = await _authService.register(
      fullName: pending.fullName!,
      email: pending.email,
      password: pending.password,
    );

    if (user == null) {
      _error = AuthError.emailTaken.message;
      return false;
    }

    _currentUser = user;
    _isAuthenticated = true;

    await _sessionService.saveSession(
      userId: user.id,
      userName: user.fullName,
      userEmail: user.email,
    );

    _pendingAuth = null;
    return true;
  }

  /// Complete login after OTP verification
  Future<bool> _completeLogin() async {
    final pending = _pendingAuth!;
    final user = await _authService.login(
      email: pending.email,
      password: pending.password,
    );

    if (user == null) {
      _error = AuthError.invalidCredentials.message;
      return false;
    }

    _currentUser = user;
    _isAuthenticated = true;

    await _sessionService.saveSession(
      userId: user.id,
      userName: user.fullName,
      userEmail: user.email,
    );

    _pendingAuth = null;
    return true;
  }

  /// Reset password for the pending email
  Future<Result<void>> resetPassword({required String newPassword}) async {
    if (_pendingAuth == null) {
      return const Failure(AuthError('No pending reset'));
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.updatePassword(
        email: _pendingAuth!.email,
        newPassword: newPassword,
      );

      _isLoading = false;
      _pendingAuth = null;

      if (!success) {
        _error = 'Password update failed';
        notifyListeners();
        return const Failure(AuthError('Password update failed'));
      }

      notifyListeners();
      return const Success(null);
    } catch (e) {
      _isLoading = false;
      _error = 'Reset failed: $e';
      notifyListeners();
      return Failure(AuthError('Reset failed', debugInfo: e.toString()));
    }
  }

  /// Logout — clears session and pending state
  Future<void> logout() async {
    await _sessionService.clearSession();
    _currentUser = null;
    _isAuthenticated = false;
    _error = null;
    _pendingAuth = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear pending auth (e.g., user navigates away from OTP screen)
  void clearPending() {
    _pendingAuth = null;
  }
}
