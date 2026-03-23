import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  BRIKOLIK DESIGN SYSTEM – Retro Purple & Blues
//  Primary brand color hierarchy:
//    Brand:       #465892 (Old Blue) / #546DA6 (Toronto)
//    Accent/CTA:  #6D5593 (Dark Amethyst) / #543D7B (Dark Pastel Indigo)
//    Neutral:     #BBC1C6 (Frosted Silver) / #968EAF (Mystic Heather)
// ─────────────────────────────────────────────

class BrikolikColors {
  // ── Brand blues ──────────────────────────────
  static const Color primary      = Color(0xFF465892); // Old Blue
  static const Color primaryLight = Color(0xFFECEEF7); // very light tint
  static const Color primaryDark  = Color(0xFF3A4A7A); // darker shade

  // ── Secondary accent (Toronto blue) ──────────
  static const Color secondary     = Color(0xFF546DA6); // Toronto
  static const Color secondaryLight = Color(0xFFEDF0F8);

  // ── CTA / Action purple ───────────────────────
  static const Color accent       = Color(0xFF6D5593); // Dark Amethyst
  static const Color accentDark   = Color(0xFF543D7B); // Dark Pastel Indigo
  static const Color accentLight  = Color(0xFFF0ECF8);

  // ── Muted / Mystic Heather ────────────────────
  static const Color muted        = Color(0xFF968EAF); // Mystic Heather
  static const Color mutedLight   = Color(0xFFF5F4F8);

  // ── Frosted Silver neutral tones ──────────────
  static const Color frostSilver  = Color(0xFFBBC1C6); // Frosted Silver

  // ── Scaffold / Surface ────────────────────────
  static const Color background     = Color(0xFFF8F9FB); // near-white cool
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2F8); // cool grey-blue tint

  // ── Text ──────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1E2340); // deep navy
  static const Color textSecondary = Color(0xFF6B6E8A); // muted navy-grey
  static const Color textHint      = Color(0xFFABAFC8); // light muted

  // ── Status ────────────────────────────────────
  static const Color success      = Color(0xFF2D9B5A);
  static const Color successLight = Color(0xFFE8F7EF);
  static const Color warning      = Color(0xFFF5A623);
  static const Color warningLight = Color(0xFFFFF8E6);
  static const Color error        = Color(0xFFD93B3B);
  static const Color errorLight   = Color(0xFFFDEDED);

  // ── Borders / Dividers ────────────────────────
  static const Color border        = Color(0xFFDDE0EE);
  static const Color borderFocused = Color(0xFF546DA6);
  static const Color divider       = Color(0xFFEAECF5);

  // ── Gradients ─────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF465892), Color(0xFF6D5593)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFECEEF7), Color(0xFFF0ECF8)],
  );

  // ── Star / rating ─────────────────────────────
  static const Color star = Color(0xFFFFC107);
}

class BrikolikSpacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;
}

class BrikolikRadius {
  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 24;
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
        secondary: BrikolikColors.accent,
        onSecondary: Colors.white,
        surface: BrikolikColors.surface,
        onSurface: BrikolikColors.textPrimary,
        error: BrikolikColors.error,
        outline: BrikolikColors.border,
      ),

      // ── AppBar ──────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: BrikolikColors.surface,
        foregroundColor: BrikolikColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Color(0x18000000),
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: BrikolikColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: BrikolikColors.textPrimary),
      ),

      // ── Elevated Button ─────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BrikolikColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BrikolikRadius.md),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // ── Outlined Button ─────────────────────────
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

      // ── Text Button ─────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BrikolikColors.accent,
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Input Decoration ────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BrikolikColors.surfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrikolikRadius.md),
          borderSide:
              const BorderSide(color: BrikolikColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrikolikRadius.md),
          borderSide:
              const BorderSide(color: BrikolikColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrikolikRadius.md),
          borderSide:
              const BorderSide(color: BrikolikColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrikolikRadius.md),
          borderSide:
              const BorderSide(color: BrikolikColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrikolikRadius.md),
          borderSide:
              const BorderSide(color: BrikolikColors.error, width: 2),
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

      // ── Card ────────────────────────────────────
      cardTheme: CardThemeData(
        color: BrikolikColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BrikolikRadius.lg),
          side: const BorderSide(color: BrikolikColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Chip ─────────────────────────────────────
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

      // ── Bottom Navigation Bar ─────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: BrikolikColors.surface,
        selectedItemColor: BrikolikColors.accent,
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

      // ── Divider ──────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: BrikolikColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ── Text Theme ───────────────────────────────
      textTheme: const TextTheme(
        displayLarge:  TextStyle(fontFamily: 'Nunito', fontSize: 32, fontWeight: FontWeight.w800, color: BrikolikColors.textPrimary),
        displayMedium: TextStyle(fontFamily: 'Nunito', fontSize: 28, fontWeight: FontWeight.w800, color: BrikolikColors.textPrimary),
        headlineLarge: TextStyle(fontFamily: 'Nunito', fontSize: 24, fontWeight: FontWeight.w700, color: BrikolikColors.textPrimary),
        headlineMedium:TextStyle(fontFamily: 'Nunito', fontSize: 20, fontWeight: FontWeight.w700, color: BrikolikColors.textPrimary),
        headlineSmall: TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w700, color: BrikolikColors.textPrimary),
        titleLarge:    TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w700, color: BrikolikColors.textPrimary),
        titleMedium:   TextStyle(fontFamily: 'Nunito', fontSize: 15, fontWeight: FontWeight.w600, color: BrikolikColors.textPrimary),
        titleSmall:    TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w600, color: BrikolikColors.textPrimary),
        bodyLarge:     TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w400, color: BrikolikColors.textPrimary),
        bodyMedium:    TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w400, color: BrikolikColors.textSecondary),
        bodySmall:     TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w400, color: BrikolikColors.textHint),
        labelLarge:    TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        labelMedium:   TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w600),
        labelSmall:    TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      ),
    );
  }
}