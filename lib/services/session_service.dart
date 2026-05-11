import 'package:shared_preferences/shared_preferences.dart';

/// Manages user session persistence using SharedPreferences.
/// Stores user ID and login timestamp to allow auto-login on app restart.
/// Lifecycle owned by GetIt — no internal singleton.
class SessionService {
  // SharedPreferences keys
  static const _keyUserId = 'session_user_id';
  static const _keyUserName = 'session_user_name';
  static const _keyUserEmail = 'session_user_email';
  static const _keyTimestamp = 'session_timestamp';

  // Session duration: 30 days
  static const int _sessionDurationDays = 30;

  /// Save session after successful login/signup
  Future<void> saveSession({
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserName, userName);
    await prefs.setString(_keyUserEmail, userEmail);
    await prefs.setString(
      _keyTimestamp,
      DateTime.now().toIso8601String(),
    );
  }

  /// Load saved session — returns user data map or null if no/expired session
  Future<Map<String, String>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_keyUserId);
    final userName = prefs.getString(_keyUserName);
    final userEmail = prefs.getString(_keyUserEmail);
    final timestamp = prefs.getString(_keyTimestamp);

    if (userId == null || timestamp == null) return null;

    // Check if session has expired
    final loginTime = DateTime.tryParse(timestamp);
    if (loginTime == null) return null;

    final daysSinceLogin = DateTime.now().difference(loginTime).inDays;
    if (daysSinceLogin > _sessionDurationDays) {
      await clearSession();
      return null;
    }

    return {
      'id': userId,
      'fullName': userName ?? 'User',
      'email': userEmail ?? '',
    };
  }

  /// Clear session on logout / password change
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyTimestamp);
  }

  /// Check if a valid session exists (quick check without loading data)
  Future<bool> hasValidSession() async {
    final session = await getSession();
    return session != null;
  }
}
