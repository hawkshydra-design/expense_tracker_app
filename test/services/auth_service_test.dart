import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/services/auth_service.dart';

/// Tests for the Firebase-backed AuthService.
/// Since we can't call real Firebase in unit tests, these tests verify
/// the service structure and _mapFirebaseUser null handling.
void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      // AuthService with default Firebase instances
      // In a real test, you'd inject mock FirebaseAuth + GoogleSignIn
      authService = AuthService();
    });

    test('currentUser returns null when not signed in', () {
      // Before any sign-in, currentUser should be null
      final user = authService.currentUser;
      expect(user, isNull);
    });

    test('authStateChanges stream emits null initially', () async {
      // The stream should emit null when no user is signed in
      final firstEvent = await authService.authStateChanges.first;
      expect(firstEvent, isNull);
    });

    test('service can be instantiated without parameters', () {
      // Verify the default constructor works (uses Firebase.instance)
      final service = AuthService();
      expect(service, isNotNull);
    });
  });
}
