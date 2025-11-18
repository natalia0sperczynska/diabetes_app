import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  String _currentTitle = "Diabetes App";

  String get currentTitle => _currentTitle;

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  String _welcomeMessage = "Welcome";

  String get welcomeMessage => _welcomeMessage;

  void setIndex(int index) {
    _selectedIndex = index;
    switch (index) {
      case 0:
        _currentTitle = "Home";
        break;
      case 1:
        _currentTitle = "Meals";
        break;
      case 2:
        _currentTitle = "Settings";
        break;
    }
    notifyListeners();
  }

  // User? _user;
  // User? get user => _user;
  void loadUserData() {
    _welcomeMessage = "Loaded data";
    notifyListeners();
  }
}
