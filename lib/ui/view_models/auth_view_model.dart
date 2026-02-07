import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  AuthStatus _status = AuthStatus.loading;
  User? _user;
  String? _errorMessage;
  UserModel? _userModel;
  StreamSubscription<UserModel?>? _userSubscription;

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  UserModel? get currentUser => _userModel;

  AuthViewModel() {
    _init();
  }

  void _init() async {
    // Add a minimum splash screen duration
    final splashDuration = Future.delayed(const Duration(milliseconds: 800));

    _authService.authStateChanges.listen((User? user) async {
      // Wait for minimum splash duration
      await splashDuration;

      _user = user;
      if (user != null) {
        _status = AuthStatus.authenticated;
        _listenToUserData(user.uid);
      } else {
        _userModel = null;
        _status = AuthStatus.unauthenticated;
        _userSubscription?.cancel();
      }
      notifyListeners();
    });
  }
  void _listenToUserData(String uid) {
    _userSubscription?.cancel();

    _userSubscription = _userService.getUserStream(uid).listen((userData) {
      _userModel = userData;
      print("AuthViewModel: User data received: ${_userModel?.gender}");
      notifyListeners();
    });
  }

  Future<bool> signIn({required String email, required String password}) async {
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
    required String name,
    required String surname,
    required int age,
    required String gender,
    required String country,
    String? phoneNumber,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;

      final userModel = UserModel(
        id: userId,
        email: email,
        name: name,
        surname: surname,
        age: age,
        gender: gender,
        country: country,
        phoneNumber: phoneNumber,
      );

      await _userService.createUser(userModel);
      _userModel = userModel;
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
      _userSubscription?.cancel();
      _userSubscription = null;
      _userModel = null;
      _user = null;
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
  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
