import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';

/// Authentication service backed by Firebase Auth + Google Sign-In.
/// Replaces the old custom SHA-256 hashing + local SQLite user storage.
///
/// Firebase handles:
/// - Password hashing (bcrypt/scrypt — industry standard)
/// - Session persistence (secure OS-level storage)
/// - Email verification emails
/// - Password reset emails
/// - Brute-force protection (auto-lockout after failed attempts)
class AuthService {
  final fb.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthService({
    fb.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  // ════════════════════════════════════════════════════════════
  // Google Sign-In (works for BOTH login and new account)
  // ════════════════════════════════════════════════════════════

  /// Sign in with Google. If the user doesn't have an account, Firebase
  /// automatically creates one. Returns null if user cancelled the popup.
  Future<User?> signInWithGoogle() async {
    // Show Google account picker
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // User cancelled

    // Get auth tokens from Google
    final googleAuth = await googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with Google credential
    final userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    return _mapFirebaseUser(userCredential.user);
  }

  // ════════════════════════════════════════════════════════════
  // Email/Password Authentication
  // ════════════════════════════════════════════════════════════

  /// Register a new user with email and password.
  /// Firebase automatically hashes the password securely.
  /// Sends a verification email to the user.
  Future<User?> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );

    // Set display name from the signup form
    await credential.user?.updateDisplayName(fullName.trim());
    // Reload to get updated profile
    await credential.user?.reload();

    // Send email verification (Firebase handles the email)
    await credential.user?.sendEmailVerification();

    return _mapFirebaseUser(_firebaseAuth.currentUser);
  }

  /// Login with email and password.
  /// Firebase verifies the hashed password on their servers.
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    return _mapFirebaseUser(credential.user);
  }

  // ════════════════════════════════════════════════════════════
  // Password Reset
  // ════════════════════════════════════════════════════════════

  /// Send a password reset email. Firebase handles the email delivery
  /// and the reset link — no SMTP credentials needed on the device.
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(
      email: email.trim().toLowerCase(),
    );
  }

  // ════════════════════════════════════════════════════════════
  // Session Management
  // ════════════════════════════════════════════════════════════

  /// Get the currently logged-in user (persisted by Firebase automatically).
  /// Returns null if no user is signed in.
  User? get currentUser => _mapFirebaseUser(_firebaseAuth.currentUser);

  /// Stream of auth state changes — useful for reactive UI updates.
  Stream<User?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(_mapFirebaseUser);

  // ════════════════════════════════════════════════════════════
  // Logout
  // ════════════════════════════════════════════════════════════

  /// Sign out from both Firebase and Google.
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  // ════════════════════════════════════════════════════════════
  // Internal: Map Firebase User → App User
  // ════════════════════════════════════════════════════════════

  User? _mapFirebaseUser(fb.User? fbUser) {
    if (fbUser == null) return null;
    return User(
      id: fbUser.uid,
      fullName: fbUser.displayName ?? 'User',
      email: fbUser.email ?? '',
      photoUrl: fbUser.photoURL,
      createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
    );
  }
}
