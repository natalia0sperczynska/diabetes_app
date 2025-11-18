import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors/app_colors.dart';

class AppTheme {
  static ThemeData get pixelTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.icelandTextTheme(ThemeData.dark().textTheme),

      colorScheme: const ColorScheme(
        brightness: Brightness.dark,

        primary: AppColors.mainBlue,
        onPrimary: Colors.white,

        secondary: AppColors.pink,
        onSecondary: Colors.white,

        tertiary: AppColors.mainComplement,

        surface: AppColors.darkBlue1,
        onSurface: Colors.white,

        surfaceContainer: AppColors.darkBlue2,
        onSurfaceVariant: Colors.white,

        background: AppColors.darkBlue2,
        onBackground: Colors.white,

        error: Colors.redAccent,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.darkBlue2,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBlue1,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.iceland(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.5,
        ),
      ),

      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.darkBlue2),
    );
  }
}
