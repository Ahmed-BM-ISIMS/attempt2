import 'package:firebase_auth/firebase_auth.dart';

/// Wraps all Firebase Auth calls.
/// Screens call this instead of using FirebaseAuth.instance directly —
/// making the auth layer swappable and testable.
class AuthService {
  AuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail({required String email}) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> sendEmailVerification() =>
      _auth.currentUser!.sendEmailVerification();

  Future<void> reloadUser() => _auth.currentUser!.reload();

  bool get isEmailVerified =>
      _auth.currentUser?.emailVerified ?? false;

  Future<void> updateDisplayName(String name) =>
      _auth.currentUser!.updateDisplayName(name);

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    final credential =
        EmailAuthProvider.credential(email: email, password: password);
    await _auth.currentUser!.reauthenticateWithCredential(credential);
    await _auth.currentUser!.delete();
    await _auth.signOut();
  }
}
