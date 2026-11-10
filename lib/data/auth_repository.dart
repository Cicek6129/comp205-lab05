import 'package:firebase_auth/firebase_auth.dart';

/// Thrown by AuthRepository with a message you can show to the user. Given.
class AuthFailure implements Exception {
  AuthFailure(this.message);
  final String message;
  @override
  String toString() => 'AuthFailure($message)';
}

/// Part 2: email + password sign-in with Firebase Authentication.
class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;

  /// Emits the signed-in user, or null after sign-out. Given.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Signs in with _auth.signInWithEmailAndPassword (email trimmed).
  /// A FirebaseAuthException becomes AuthFailure(messageFor(e.code)).
  Future<void> signIn(String email, String password) async {
    // TODO(2)
    throw UnimplementedError('signIn');
  }

  /// Same as signIn, with _auth.createUserWithEmailAndPassword.
  Future<void> signUp(String email, String password) async {
    // TODO(2)
    throw UnimplementedError('signUp');
  }

  Future<void> signOut() async {
    // TODO(2)
    throw UnimplementedError('signOut');
  }

  /// A friendly message for a FirebaseAuthException code:
  ///   'invalid-email'          -> 'The email address is not valid.'
  ///   'weak-password'          -> 'The password must be at least 6 characters.'
  ///   'email-already-in-use'   -> 'An account already exists for this email.'
  ///   'invalid-credential', 'wrong-password', 'user-not-found'
  ///                            -> 'Wrong email or password.'
  ///   'network-request-failed' -> 'No connection. Check your network.'
  ///   anything else            -> 'Sign-in failed. Please try again.'
  static String messageFor(String code) {
    // TODO(2) - a switch expression is the cleanest way
    throw UnimplementedError('messageFor');
  }
}
