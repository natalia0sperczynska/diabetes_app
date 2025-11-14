import 'package:flutter/material.dart';
class HomeViewModel extends ChangeNotifier{
  HomeViewModel();

  String _welcomeMessage = "Welcome to Diabetes App";
  String get welcomeMessage => _welcomeMessage;

  // User? _user;
  // User? get user => _user;
  void loadUserData() {
    _welcomeMessage = "Loaded data";
    notifyListeners();
  }
}