import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user?.updateDisplayName(name.trim());
      await credential.user?.reload();

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_messageFor(e.code));
    }
  }

  Future<UserCredential> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_messageFor(e.code));
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_messageFor(e.code));
    }
  }

  Future<void> updateName(String name) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please log in first.');
    }

    await user.updateDisplayName(name.trim());
    await user.reload();
  }

  String _messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'network-request-failed':
        return 'Check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'operation-not-allowed':
        return 'Enable Email/Password in Firebase Authentication.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
