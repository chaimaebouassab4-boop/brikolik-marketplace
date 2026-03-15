import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  BRIKOLIK DESIGN SYSTEM
//  Inspired by Uber / TaskRabbit — warm, trustworthy, action-first
// ─────────────────────────────────────────────

class BrikolikColors {
  // Primary — warm amber-orange (tool/craft energy)
  static const Color primary = Color(0xFFE8650A);
  static const Color primaryLight = Color(0xFFFFF0E6);
  static const Color primaryDark = Color(0xFFBF4D00);

  // Neutral surface palette
  static const Color background = Color(0xFFF8F7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2F0ED);

  // Text
  static const Color textPrimary = Color(0xFF1A1512);
  static const Color textSecondary = Color(0xFF6B6560);
  static const Color textHint = Color(0xFFADA8A3);

  // Status
  static const Color success = Color(0xFF2D9B5A);
  static const Color successLight = Color(0xFFE8F7EF);
  static const Color warning = Color(0xFFF5A623);
  static const Color warningLight = Color(0xFFFFF8E6);
  static const Color error = Color(0xFFD93B3B);
  static const Color errorLight = Color(0xFFFDEDED);

  // Border
  static const Color border = Color(0xFFE8E4DF);
  static const Color borderFocused = Color(0xFFE8650A);

  // Divider
  static const Color divider = Color(0xFFF0EDE9);

  // Star / rating
  static const Color star = Color(0xFFFFC107);
}

class BrikolikSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class BrikolikRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      scaffoldBackgroundColor: BrikolikColors.background,
      colorScheme: const ColorScheme.light(
        primary: BrikolikColors.primary,
        onPrimary: Colors.white,
        surface: BrikolikColors.surface,
        onSurface: BrikolikColors.textPrimary,
        error: BrikolikColors.error,
        outline: BrikolikColors.border,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: BrikolikColors.surface,
        foregroundColor: BrikolikColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Color(0x1A000000),
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: BrikolikColors.textPrimary,
        ),
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BrikolikColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BrikolikRadius.md),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BrikolikColors.primary,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: BrikolikColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BrikolikRadius.md),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BrikolikColors.primary,
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BrikolikColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrikolikRadius.md),
          borderSide: const BorderSide(color: BrikolikColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrikolikRadius.md),
          borderSide: const BorderSide(color: BrikolikColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrikolikRadius.md),
          borderSide: const BorderSide(color: BrikolikColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrikolikRadius.md),
          borderSide: const BorderSide(color: BrikolikColors.error, width: 1.5),
        ),
        hintStyle: const TextStyle(
          color: BrikolikColors.textHint,
          fontFamily: 'Nunito',
          fontSize: 15,
        ),
        labelStyle: const TextStyle(
          color: BrikolikColors.textSecondary,
          fontFamily: 'Nunito',
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(
          color: BrikolikColors.primary,
          fontFamily: 'Nunito',
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: BrikolikColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BrikolikRadius.lg),
          side: const BorderSide(color: BrikolikColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: BrikolikColors.surfaceVariant,
        selectedColor: BrikolikColors.primaryLight,
        labelStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BrikolikRadius.full),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // Bottom navigation bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: BrikolikColors.surface,
        selectedItemColor: BrikolikColors.primary,
        unselectedItemColor: BrikolikColors.textHint,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: BrikolikColors.divider,
        thickness: 1,
        space: 1,
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Nunito', fontSize: 32, fontWeight: FontWeight.w800, color: BrikolikColors.textPrimary),
        displayMedium: TextStyle(fontFamily: 'Nunito', fontSize: 28, fontWeight: FontWeight.w800, color: BrikolikColors.textPrimary),
        headlineLarge: TextStyle(fontFamily: 'Nunito', fontSize: 24, fontWeight: FontWeight.w700, color: BrikolikColors.textPrimary),
        headlineMedium: TextStyle(fontFamily: 'Nunito', fontSize: 20, fontWeight: FontWeight.w700, color: BrikolikColors.textPrimary),
        headlineSmall: TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w700, color: BrikolikColors.textPrimary),
        titleLarge: TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w700, color: BrikolikColors.textPrimary),
        titleMedium: TextStyle(fontFamily: 'Nunito', fontSize: 15, fontWeight: FontWeight.w600, color: BrikolikColors.textPrimary),
        titleSmall: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w600, color: BrikolikColors.textPrimary),
        bodyLarge: TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w400, color: BrikolikColors.textPrimary),
        bodyMedium: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w400, color: BrikolikColors.textSecondary),
        bodySmall: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w400, color: BrikolikColors.textHint),
        labelLarge: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        labelMedium: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      ),
    );
  }
}