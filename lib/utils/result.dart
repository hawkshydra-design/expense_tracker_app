/// Typed result type for operation outcomes.
/// Replaces raw try/catch with explicit success/failure.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => switch (this) {
        Success(value: final v) => v,
        Failure() => null,
      };

  AppError? get errorOrNull => switch (this) {
        Success() => null,
        Failure(error: final e) => e,
      };

  /// Map success value to another type
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Success(value: final v) => Success(transform(v)),
        Failure(error: final e) => Failure(e),
      };
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);
}

/// Typed application errors with user-friendly messages.
sealed class AppError {
  final String message;
  final String? debugInfo;

  const AppError(this.message, {this.debugInfo});

  @override
  String toString() => 'AppError($message)';
}

/// Authentication-related errors
class AuthError extends AppError {
  const AuthError(super.message, {super.debugInfo});

  static const emailTaken = AuthError('Email already registered');
  static const invalidCredentials = AuthError('Invalid email or password');
  static const registrationFailed = AuthError('Registration failed. Please try again.');
  static const loginFailed = AuthError('Login failed. Please try again.');
  static const userNotFound = AuthError('No account found with this email');
}

/// OTP-related errors
class OtpError extends AppError {
  const OtpError(super.message, {super.debugInfo});

  static const rateLimited = OtpError('Please wait before requesting another code');
  static const sendFailed = OtpError('Failed to send verification code. Please try again.');
  static const invalidCode = OtpError('Invalid or expired code. Please try again.');
  static const expired = OtpError('Code has expired. Please request a new one.');
  static const maxAttempts = OtpError('Too many attempts. Please request a new code.');
}

/// Database/persistence errors
class DataError extends AppError {
  const DataError(super.message, {super.debugInfo});

  static const loadFailed = DataError('Failed to load data');
  static const saveFailed = DataError('Failed to save data');
  static const deleteFailed = DataError('Failed to delete data');
  static const updateFailed = DataError('Failed to update data');
}

/// Network errors
class NetworkError extends AppError {
  const NetworkError(super.message, {super.debugInfo});

  static const noConnection = NetworkError('No internet connection');
  static const timeout = NetworkError('Request timed out');
}
