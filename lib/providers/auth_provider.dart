import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vitasora/core/services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Provides reactive auth state to the widget tree via Provider.
/// Usage:
///   context.watch<AppAuthProvider>().status
///   context.read<AppAuthProvider>().signOut()
class AppAuthProvider extends ChangeNotifier {
  AppAuthProvider({AuthService? authService})
      : _service = authService ?? AuthService() {
    _subscription = _service.authStateChanges.listen(_onAuthStateChanged);
  }

  final AuthService _service;
  late final StreamSubscription<User?> _subscription;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  void _onAuthStateChanged(User? user) {
    _user = user;
    _status = user != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _service.signIn(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyAuthError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createAccount({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _service.createAccount(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyAuthError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
  }

  Future<bool> sendPasswordReset({required String email}) async {
    _setLoading(true);
    try {
      await _service.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyAuthError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => 'No account found for that email.',
      'wrong-password' => 'Incorrect password.',
      'email-already-in-use' => 'This email is already registered.',
      'invalid-email' => 'Please enter a valid email address.',
      'weak-password' => 'Password must be at least 6 characters.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      _ => e.message ?? 'Authentication failed.',
    };
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
