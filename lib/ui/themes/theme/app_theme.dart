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

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mainBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
    );
  }

  static ThemeData get pixelLightTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.icelandTextTheme(ThemeData.light().textTheme),

      colorScheme: const ColorScheme(
        brightness: Brightness.light,

        primary: AppColors.lightBlue1,
        onPrimary: Colors.black,

        secondary: AppColors.pink,
        onSecondary: Colors.white,

        tertiary: AppColors.mainComplement,

        surface: Colors.white,
        onSurface: Colors.black,

        surfaceContainer: Color(0xFFF6F6F6),
        onSurfaceVariant: Colors.black,

        error: Colors.redAccent,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: const Color(0xFFF6F6F6),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.iceland(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: 1.5,
        ),
      ),

      drawerTheme: const DrawerThemeData(backgroundColor: Colors.white),
    );
  }

  // Pope Yellow Dark Theme
  static ThemeData get popeYellowTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.icelandTextTheme(ThemeData.dark().textTheme),

      colorScheme: const ColorScheme(
        brightness: Brightness.dark,

        primary: AppColors.popeYellowPrimaryDark,
        onPrimary: AppColors.popeYellowOnPrimaryDark,

        secondary: AppColors.popeYellowSecondaryDark,
        onSecondary: Colors.white,

        tertiary: AppColors.mainComplement,

        surface: AppColors.popeYellowSurfaceDark,
        onSurface: Colors.white,

        surfaceContainer: AppColors.popeYellowSurfaceDark,
        onSurfaceVariant: Colors.white,

        error: Colors.redAccent,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.popeYellowBackgroundDark,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.popeYellowSurfaceDark,
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

      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.popeYellowBackgroundDark),
    );
  }

  // Pope Yellow Light Theme
  static ThemeData get popeYellowLightTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.icelandTextTheme(ThemeData.light().textTheme),

      colorScheme: const ColorScheme(
        brightness: Brightness.light,

        primary: AppColors.popeYellowPrimaryLight,
        onPrimary: AppColors.popeYellowOnPrimaryLight,

        secondary: AppColors.popeYellowSecondaryLight,
        onSecondary: Colors.white,

        tertiary: AppColors.mainComplement,

        surface: AppColors.popeYellowSurfaceLight,
        onSurface: Colors.black,

        surfaceContainer: AppColors.popeYellowSurfaceLight,
        onSurfaceVariant: Colors.black,

        error: Colors.redAccent,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.popeYellowBackgroundLight,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.popeYellowSurfaceLight,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.iceland(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: 1.5,
        ),
      ),

      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.popeYellowBackgroundLight),
    );
  }

  // Forest Green Dark Theme
  static ThemeData get forestGreenTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.icelandTextTheme(ThemeData.dark().textTheme),

      colorScheme: const ColorScheme(
        brightness: Brightness.dark,

        primary: AppColors.forestGreenPrimaryDark,
        onPrimary: AppColors.forestGreenOnPrimaryDark,

        secondary: AppColors.forestGreenSecondaryDark,
        onSecondary: Colors.white,

        tertiary: AppColors.mainComplement,

        surface: AppColors.forestGreenSurfaceDark,
        onSurface: Colors.white,

        surfaceContainer: AppColors.forestGreenSurfaceDark,
        onSurfaceVariant: Colors.white,

        error: Colors.redAccent,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.forestGreenBackgroundDark,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.forestGreenSurfaceDark,
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

      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.forestGreenBackgroundDark),
    );
  }

  // Forest Green Light Theme
  static ThemeData get forestGreenLightTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.icelandTextTheme(ThemeData.light().textTheme),

      colorScheme: const ColorScheme(
        brightness: Brightness.light,

        primary: AppColors.forestGreenPrimaryLight,
        onPrimary: AppColors.forestGreenOnPrimaryLight,

        secondary: AppColors.forestGreenSecondaryLight,
        onSecondary: Colors.white,

        tertiary: AppColors.mainComplement,

        surface: AppColors.forestGreenSurfaceLight,
        onSurface: Colors.black,

        surfaceContainer: AppColors.forestGreenSurfaceLight,
        onSurfaceVariant: Colors.black,

        error: Colors.redAccent,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.forestGreenBackgroundLight,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.forestGreenSurfaceLight,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.iceland(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: 1.5,
        ),
      ),

      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.forestGreenBackgroundLight),
    );
  }

  // Sunset Orange dark theme
  static ThemeData get sunsetOrangeTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.icelandTextTheme(ThemeData.dark().textTheme),

      colorScheme: const ColorScheme(
        brightness: Brightness.dark,

        primary: AppColors.sunsetOrangePrimaryDark,
        onPrimary: AppColors.sunsetOrangeOnPrimaryDark,

        secondary: AppColors.sunsetOrangeSecondaryDark,
        onSecondary: Colors.white,

        tertiary: AppColors.mainComplement,

        surface: AppColors.sunsetOrangeSurfaceDark,
        onSurface: Colors.white,

        surfaceContainer: AppColors.sunsetOrangeSurfaceDark,
        onSurfaceVariant: Colors.white,

        error: Colors.redAccent,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.sunsetOrangeBackgroundDark,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.sunsetOrangeSurfaceDark,
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

      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.sunsetOrangeBackgroundDark),
    );
  }

  // Sunset Orange light theme
  static ThemeData get sunsetOrangeLightTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.icelandTextTheme(ThemeData.light().textTheme),

      colorScheme: const ColorScheme(
        brightness: Brightness.light,

        primary: AppColors.sunsetOrangePrimaryLight,
        onPrimary: AppColors.sunsetOrangeOnPrimaryLight,

        secondary: AppColors.sunsetOrangeSecondaryLight,
        onSecondary: Colors.white,

        tertiary: AppColors.mainComplement,

        surface: AppColors.sunsetOrangeSurfaceLight,
        onSurface: Colors.black,

        surfaceContainer: AppColors.sunsetOrangeSurfaceLight,
        onSurfaceVariant: Colors.black,

        error: Colors.redAccent,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.sunsetOrangeBackgroundLight,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.sunsetOrangeSurfaceLight,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.iceland(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: 1.5,
        ),
      ),

      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.sunsetOrangeBackgroundLight),
    );
  }

  // Deep Purple dark theme
  static ThemeData get deepPurpleTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.icelandTextTheme(ThemeData.dark().textTheme),

      colorScheme: const ColorScheme(
        brightness: Brightness.dark,

        primary: AppColors.deepPurplePrimaryDark,
        onPrimary: AppColors.deepPurpleOnPrimaryDark,

        secondary: AppColors.deepPurpleSecondaryDark,
        onSecondary: Colors.white,

        tertiary: AppColors.mainComplement,

        surface: AppColors.deepPurpleSurfaceDark,
        onSurface: Colors.white,

        surfaceContainer: AppColors.deepPurpleSurfaceDark,
        onSurfaceVariant: Colors.white,

        error: Colors.redAccent,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.deepPurpleBackgroundDark,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.deepPurpleSurfaceDark,
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

      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.deepPurpleBackgroundDark),
    );
  }

  // Deep Purple light theme
  static ThemeData get deepPurpleLightTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.icelandTextTheme(ThemeData.light().textTheme),

      colorScheme: const ColorScheme(
        brightness: Brightness.light,

        primary: AppColors.deepPurplePrimaryLight,
        onPrimary: AppColors.deepPurpleOnPrimaryLight,

        secondary: AppColors.deepPurpleSecondaryLight,
        onSecondary: Colors.white,

        tertiary: AppColors.mainComplement,

        surface: AppColors.deepPurpleSurfaceLight,
        onSurface: Colors.black,

        surfaceContainer: AppColors.deepPurpleSurfaceLight,
        onSurfaceVariant: Colors.black,

        error: Colors.redAccent,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.deepPurpleBackgroundLight,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.deepPurpleSurfaceLight,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.iceland(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: 1.5,
        ),
      ),

      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.deepPurpleBackgroundLight),
    );
  }

  // Ocean Blue dark theme
  static ThemeData get oceanBlueTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.icelandTextTheme(ThemeData.dark().textTheme),

      colorScheme: const ColorScheme(
        brightness: Brightness.dark,

        primary: AppColors.oceanBluePrimaryDark,
        onPrimary: AppColors.oceanBlueOnPrimaryDark,

        secondary: AppColors.oceanBlueSecondaryDark,
        onSecondary: Colors.white,

        tertiary: AppColors.mainComplement,

        surface: AppColors.oceanBlueSurfaceDark,
        onSurface: Colors.white,

        surfaceContainer: AppColors.oceanBlueSurfaceDark,
        onSurfaceVariant: Colors.white,

        error: Colors.redAccent,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.oceanBlueBackgroundDark,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.oceanBlueSurfaceDark,
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

      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.oceanBlueBackgroundDark),
    );
  }

  // Ocean Blue light theme
  static ThemeData get oceanBlueLightTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.icelandTextTheme(ThemeData.light().textTheme),

      colorScheme: const ColorScheme(
        brightness: Brightness.light,

        primary: AppColors.oceanBluePrimaryLight,
        onPrimary: AppColors.oceanBlueOnPrimaryLight,

        secondary: AppColors.oceanBlueSecondaryLight,
        onSecondary: Colors.white,

        tertiary: AppColors.mainComplement,

        surface: AppColors.oceanBlueSurfaceLight,
        onSurface: Colors.black,

        surfaceContainer: AppColors.oceanBlueSurfaceLight,
        onSurfaceVariant: Colors.black,

        error: Colors.redAccent,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.oceanBlueBackgroundLight,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.oceanBlueSurfaceLight,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.iceland(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: 1.5,
        ),
      ),

      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.oceanBlueBackgroundLight),
    );
  }
  // Wewnątrz klasy AppTheme:

  static ThemeData get cyberpunkTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.icelandTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: AppColors.neonCyan,
        displayColor: Colors.white,
      ),

      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.neonPink,
        onPrimary: Colors.black,
        secondary: AppColors.neonCyan,
        onSecondary: Colors.black,
        tertiary: AppColors.neonGreen,

        surface: AppColors.cyberDarkBlue,
        onSurface: AppColors.neonCyan,

        surfaceContainer: AppColors.cyberBlack,

        error: Colors.redAccent,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.cyberBlack,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cyberBlack,
        foregroundColor: AppColors.neonPink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.iceland(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.neonPink,
          letterSpacing: 2.0,
        ),
        iconTheme: const IconThemeData(color: AppColors.neonCyan),
      ),

      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.cyberDarkBlue,
        scrimColor: Colors.transparent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyberDarkBlue,
          foregroundColor: AppColors.neonPink,
          elevation: 10,
          shadowColor: AppColors.neonPink,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.iceland(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5
          ),
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.neonPink, width: 2), // Neonowa ramka
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cyberDarkBlue,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.neonCyan, width: 2),
          borderRadius: BorderRadius.zero,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.neonPink, width: 3),
          borderRadius: BorderRadius.zero,
        ),
        labelStyle: GoogleFonts.iceland(color: AppColors.neonGreen, fontSize: 18),
        hintStyle: GoogleFonts.iceland(color: AppColors.neonCyan.withOpacity(0.5)),
      ),
    );
  }
}
