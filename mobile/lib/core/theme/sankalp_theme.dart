import 'package:flutter/material.dart';

/// Supported Sankalp theme modes.
enum SankalpThemeMode {
  day, // Default: Yellow and Crisp White
  dark, // Dark Slate and Amber Yellow
  night, // Pure AMOLED Black and Vivid Yellow
  custom, // User-configured custom palette
}

/// Central Theme Engine for Sankalp with Material 3 styling.
class SankalpTheme {
  // Brand Color Palette extracted from the official Sankalp logo
  static const Color brandYellow = Color(0xFFFFC727); // Exact vibrant logo yellow
  static const Color brandYellowLight = Color(0xFFFFF7D6); // Soft yellow surface
  static const Color brandYellowDark = Color(0xFFE5A800); // Deep golden yellow
  static const Color brandBlack = Color(0xFF1A1A1A); // Ink brush black from logo
  static const Color brandWhite = Color(0xFFFFFFFF); // Clean white

  /// DAY MODE (Default): Yellow and White
  static ThemeData get dayTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFCFBF7), // Warm paper white
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: brandYellow,
        onPrimary: brandBlack,
        secondary: Color(0xFF333333),
        onSecondary: brandWhite,
        surface: brandWhite,
        onSurface: Color(0xFF1E1E1E),
        error: Color(0xFFD32F2F),
        onError: brandWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: brandWhite,
        foregroundColor: brandBlack,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: brandWhite,
        elevation: 1,
        shadowColor: const Color(0x1A000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFF1EAD9), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandYellow,
          foregroundColor: brandBlack,
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  /// DARK MODE: Charcoal Slate with Vibrant Yellow accents
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF12141A),
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: brandYellow,
        onPrimary: brandBlack,
        secondary: Color(0xFFE0E0E0),
        onSecondary: brandBlack,
        surface: Color(0xFF1C1F28),
        onSurface: Color(0xFFF5F5F5),
        error: Color(0xFFFF5252),
        onError: brandBlack,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1C1F28),
        foregroundColor: brandWhite,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Color(0xFF1C1F28),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2B303E), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandYellow,
          foregroundColor: brandBlack,
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  /// NIGHT MODE: Pure AMOLED True Black (0x000000) for maximum power saving
  static ThemeData get nightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF000000),
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: brandYellow,
        onPrimary: brandBlack,
        secondary: brandWhite,
        onSecondary: brandBlack,
        surface: Color(0xFF0F0F0F),
        onSurface: brandWhite,
        error: Color(0xFFFF5252),
        onError: brandBlack,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        foregroundColor: brandWhite,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Color(0xFF0F0F0F),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF222222), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandYellow,
          foregroundColor: brandBlack,
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  /// CUSTOM MODE: Allows user to supply custom primary color while retaining accessibility
  static ThemeData customTheme({
    required Color primaryColor,
    required bool isDark,
  }) {
    final base = isDark ? darkTheme : dayTheme;
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primaryColor,
        onPrimary: primaryColor.computeLuminance() > 0.5 ? brandBlack : brandWhite,
      ),
    );
  }
}
