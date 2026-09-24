import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/result.dart';

/// Centralized auth state management backed by Firebase Auth.
///
/// Simplified from the old OTP-based flow:
/// - No more _PendingAuth (credentials aren't held in memory)
/// - No more OtpService (Firebase handles email verification)
/// - No more SessionService (Firebase persists sessions automatically)
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider({required AuthService authService})
      : _authService = authService;

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;
  User? _currentUser;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;
  User? get currentUser => _currentUser;
  String get userName => _currentUser?.fullName ?? 'User';
  String get userEmail => _currentUser?.email ?? '';
  String get userId => _currentUser?.id ?? '';
  String? get userPhotoUrl => _currentUser?.photoUrl;

  // ════════════════════════════════════════════════════════════
  // Auto-Login (Firebase persists sessions automatically)
  // ════════════════════════════════════════════════════════════

  /// Check if a user is already signed in from a previous session.
  /// Firebase stores the auth token securely — no SharedPreferences needed.
  Future<bool> tryAutoLogin() async {
    try {
      _currentUser = _authService.currentUser;
      if (_currentUser != null) {
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════
  // Google Sign-In (login + signup in one)
  // ════════════════════════════════════════════════════════════

  /// Sign in with Google. Works for both new and existing users.
  /// Firebase auto-creates account if user doesn't exist.
  Future<Result<void>> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();

      _isLoading = false;

      if (user == null) {
        // User cancelled the Google popup
        notifyListeners();
        return const Failure(AuthError('Sign-in cancelled'));
      }

      _currentUser = user;
      _isAuthenticated = true;
      notifyListeners();
      return const Success(null);
    } on fb.FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = _mapFirebaseError(e);
      notifyListeners();
      return Failure(AuthError(_error!, debugInfo: e.code));
    } catch (e) {
      _isLoading = false;
      _error = 'Google sign-in failed. Please try again.';
      notifyListeners();
      return Failure(AuthError(_error!, debugInfo: e.toString()));
    }
  }

  // ════════════════════════════════════════════════════════════
  // Email/Password Login (direct — no OTP step)
  // ════════════════════════════════════════════════════════════

  /// Login with email and password.
  /// Goes directly to authenticated state — no OTP needed.
  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.login(
        email: email,
        password: password,
      );

      _isLoading = false;

      if (user == null) {
        _error = AuthError.invalidCredentials.message;
        notifyListeners();
        return const Failure(AuthError.invalidCredentials);
      }

      _currentUser = user;
      _isAuthenticated = true;
      notifyListeners();
      return const Success(null);
    } on fb.FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = _mapFirebaseError(e);
      notifyListeners();
      return Failure(AuthError(_error!, debugInfo: e.code));
    } catch (e) {
      _isLoading = false;
      _error = 'Login failed. Please try again.';
      notifyListeners();
      return Failure(AuthError(_error!, debugInfo: e.toString()));
    }
  }

  // ════════════════════════════════════════════════════════════
  // Email/Password Signup (direct — no OTP step)
  // ════════════════════════════════════════════════════════════

  /// Register a new user with email and password.
  /// Firebase sends a verification email automatically.
  Future<Result<void>> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
      );

      _isLoading = false;

      if (user == null) {
        _error = AuthError.registrationFailed.message;
        notifyListeners();
        return const Failure(AuthError.registrationFailed);
      }

      _currentUser = user;
      _isAuthenticated = true;
      notifyListeners();
      return const Success(null);
    } on fb.FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = _mapFirebaseError(e);
      notifyListeners();
      return Failure(AuthError(_error!, debugInfo: e.code));
    } catch (e) {
      _isLoading = false;
      _error = 'Signup failed. Please try again.';
      notifyListeners();
      return Failure(AuthError(_error!, debugInfo: e.toString()));
    }
  }

  // ════════════════════════════════════════════════════════════
  // Forgot Password (Firebase sends the email)
  // ════════════════════════════════════════════════════════════

  /// Send a password reset email via Firebase.
  /// No SMTP credentials needed — Firebase handles email delivery.
  Future<Result<void>> forgotPassword({required String email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);

      _isLoading = false;
      notifyListeners();
      return const Success(null);
    } on fb.FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = _mapFirebaseError(e);
      notifyListeners();
      return Failure(AuthError(_error!, debugInfo: e.code));
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to send reset email. Please try again.';
      notifyListeners();
      return Failure(AuthError(_error!, debugInfo: e.toString()));
    }
  }

  // ════════════════════════════════════════════════════════════
  // Logout
  // ════════════════════════════════════════════════════════════

  /// Sign out from Firebase and Google.
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════
  // Utilities
  // ════════════════════════════════════════════════════════════

  /// Clear displayed error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Map Firebase error codes to user-friendly messages
  String _mapFirebaseError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Invalid email or password';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'email-already-in-use':
        return 'Email already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'network-request-failed':
        return 'No internet connection';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email. Try a different sign-in method.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
