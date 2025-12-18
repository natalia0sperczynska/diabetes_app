import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  AuthViewModel() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _authService.getErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'An unexpected error occurred.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (displayName != null && displayName.isNotEmpty) {
        await _authService.updateDisplayName(displayName);
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _authService.getErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'An unexpected error occurred.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _authService.sendPasswordResetEmail(email);

      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _authService.getErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'An unexpected error occurred.';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      await _authService.signOut();

      _status = AuthStatus.unauthenticated;
      _user = null;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Failed to sign out.';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}
