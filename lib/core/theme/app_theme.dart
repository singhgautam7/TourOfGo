import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Spacing constants (same values as Kuber) ─────────────────────────────────
class KuberSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

// ── Radius constants (same values as Kuber) ───────────────────────────────────
class KuberRadius {
  static const sm = 4.0;
  static const md = 8.0;
  static const lg = 12.0;
  static const xl = 24.0;
  static const full = 999.0;
}

// ── Dark theme color palette ──────────────────────────────────────────────────
class GoTourColors {
  static const background = Color(0xFF000000);
  static const surfaceCard = Color(0xFF0D0D10);
  static const surfaceMuted = Color(0xFF18181B);
  static const border = Color(0xFF27272A);
  static const borderMuted = Color(0xFF3F3F46);
  static const textPrimary = Color(0xFFFAFAFA);
  static const textSecondary = Color(0xFFA1A1AA);
  static const accent = Color(0xFF29B6D5); // Go cyan — dark mode
  static const accentSubtle = Color(0x1A29B6D5);
}

// ── Light theme color palette ─────────────────────────────────────────────────
class GoTourLightColors {
  static const background = Color(0xFFFFFFFF);
  static const surfaceCard = Color(0xFFFAFAFA);
  static const surfaceMuted = Color(0xFFF4F4F5);
  static const border = Color(0xFFE4E4E7);
  static const borderMuted = Color(0xFFD4D4D8);
  static const textPrimary = Color(0xFF09090B);
  static const textSecondary = Color(0xFF71717A);
  static const accent = Color(0xFF00ACD7); // Go cyan — light mode
  static const accentSubtle = Color(0x1A00ACD7);
}

// ── App theme builder ─────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData dark() {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    const cs = ColorScheme.dark(
      surface: GoTourColors.background,
      onSurface: GoTourColors.textPrimary,
      onSurfaceVariant: GoTourColors.textSecondary,
      primary: GoTourColors.accent,
      onPrimary: Colors.white,
      primaryContainer: GoTourColors.accentSubtle,
      onPrimaryContainer: GoTourColors.accent,
      secondary: GoTourColors.accent,
      onSecondary: Colors.white,
      error: Color(0xFFEF4444),
      onError: Colors.white,
      errorContainer: Color(0x1AEF4444),
      onErrorContainer: Color(0xFFEF4444),
      surfaceContainer: GoTourColors.surfaceCard,
      surfaceContainerHigh: GoTourColors.surfaceMuted,
      outline: GoTourColors.border,
      outlineVariant: GoTourColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      scaffoldBackgroundColor: GoTourColors.background,
      cardTheme: CardThemeData(
        color: GoTourColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          side: const BorderSide(color: GoTourColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GoTourColors.surfaceCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          borderSide: const BorderSide(color: GoTourColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          borderSide: const BorderSide(color: GoTourColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          borderSide: const BorderSide(color: GoTourColors.accent, width: 2),
        ),
        hintStyle: const TextStyle(color: GoTourColors.textSecondary),
        labelStyle: const TextStyle(color: GoTourColors.textSecondary),
      ),
      dividerTheme: const DividerThemeData(
        color: GoTourColors.border,
        thickness: 0.5,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: GoTourColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: GoTourColors.textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: GoTourColors.surfaceCard,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: GoTourColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          side: const BorderSide(color: GoTourColors.border),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: GoTourColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(KuberRadius.lg),
          ),
          side: BorderSide(color: GoTourColors.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: GoTourColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          side: const BorderSide(color: GoTourColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: GoTourColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GoTourColors.textPrimary,
          side: const BorderSide(color: GoTourColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GoTourColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: GoTourColors.accent,
        linearTrackColor: GoTourColors.surfaceMuted,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: GoTourColors.surfaceMuted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
      ),
    );
  }

  static ThemeData light() {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);

    const cs = ColorScheme.light(
      surface: GoTourLightColors.background,
      onSurface: GoTourLightColors.textPrimary,
      onSurfaceVariant: GoTourLightColors.textSecondary,
      primary: GoTourLightColors.accent,
      onPrimary: Colors.white,
      primaryContainer: GoTourLightColors.accentSubtle,
      onPrimaryContainer: GoTourLightColors.accent,
      secondary: GoTourLightColors.accent,
      onSecondary: Colors.white,
      error: Color(0xFFDC2626),
      onError: Colors.white,
      errorContainer: Color(0x1ADC2626),
      onErrorContainer: Color(0xFFDC2626),
      surfaceContainer: GoTourLightColors.surfaceCard,
      surfaceContainerHigh: GoTourLightColors.surfaceMuted,
      outline: GoTourLightColors.border,
      outlineVariant: GoTourLightColors.borderMuted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      scaffoldBackgroundColor: GoTourLightColors.background,
      cardTheme: CardThemeData(
        color: GoTourLightColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          side: const BorderSide(color: GoTourLightColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GoTourLightColors.surfaceCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          borderSide: const BorderSide(color: GoTourLightColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          borderSide: const BorderSide(color: GoTourLightColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          borderSide:
              const BorderSide(color: GoTourLightColors.accent, width: 2),
        ),
        hintStyle:
            const TextStyle(color: GoTourLightColors.textSecondary),
        labelStyle:
            const TextStyle(color: GoTourLightColors.textSecondary),
      ),
      dividerTheme: const DividerThemeData(
        color: GoTourLightColors.border,
        thickness: 0.5,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: GoTourLightColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: GoTourLightColors.textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: GoTourLightColors.surfaceCard,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: GoTourLightColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          side: const BorderSide(color: GoTourLightColors.border),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: GoTourLightColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(KuberRadius.lg),
          ),
          side: BorderSide(color: GoTourLightColors.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: GoTourLightColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          side: const BorderSide(color: GoTourLightColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: GoTourLightColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GoTourLightColors.textPrimary,
          side: const BorderSide(color: GoTourLightColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GoTourLightColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: GoTourLightColors.accent,
        linearTrackColor: GoTourLightColors.surfaceMuted,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: GoTourLightColors.surfaceMuted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
      ),
    );
  }
}
