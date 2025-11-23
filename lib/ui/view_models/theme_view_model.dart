import 'package:flutter/material.dart';
import '../themes/theme/app_theme.dart';

class ThemeViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  String _selectedTheme = 'pixel'; // default theme name

  ThemeMode get themeMode => _themeMode;
  String get selectedTheme => _selectedTheme;

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  void setTheme(String themeName) {
    _selectedTheme = themeName;
    notifyListeners();
  }

  // New getters to return ThemeData based on selectedTheme
  ThemeData get lightThemeData {
    switch (_selectedTheme) {
      case 'popeYellow':
        return AppTheme.popeYellowLightTheme;
      case 'forestGreen':
        return AppTheme.forestGreenLightTheme;
      case 'sunsetOrange':
        return AppTheme.sunsetOrangeLightTheme;
      case 'deepPurple':
        return AppTheme.deepPurpleLightTheme;
      case 'oceanBlue':
        return AppTheme.oceanBlueLightTheme;
      case 'pixel':
      default:
        return AppTheme.pixelLightTheme;
    }
  }

  ThemeData get darkThemeData {
    switch (_selectedTheme) {
      case 'popeYellow':
        return AppTheme.popeYellowTheme;
      case 'forestGreen':
        return AppTheme.forestGreenTheme;
      case 'sunsetOrange':
        return AppTheme.sunsetOrangeTheme;
      case 'deepPurple':
        return AppTheme.deepPurpleTheme;
      case 'oceanBlue':
        return AppTheme.oceanBlueTheme;
      case 'pixel':
      default:
        return AppTheme.pixelTheme;
    }
  }
}
