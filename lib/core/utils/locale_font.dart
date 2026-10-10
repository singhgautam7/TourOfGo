import 'package:flutter/material.dart';

// Ported from Kuber `core/utils/locale_font.dart`, English only: every family
// is engine-registered in pubspec `fonts:`, so nothing here loads a font at
// runtime (a runtime load parses on the UI thread and relayouts every route).

/// The UI face, Inter. Use this, or a [TextTheme] role, for all UI text.
TextStyle localeFont({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
  TextDecoration? decoration,
  Color? decorationColor,
  FontStyle? fontStyle,
  List<FontFeature>? fontFeatures,
  Color? backgroundColor,
}) {
  return TextStyle(
    fontFamily: 'Inter',
    backgroundColor: backgroundColor,
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height ?? 1.30,
    decoration: decoration,
    decorationColor: decorationColor,
    fontStyle: fontStyle,
    fontFeatures: fontFeatures,
  );
}

/// The code face, JetBrains Mono: Go source, output, inline code.
TextStyle monoFont({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
  TextDecoration? decoration,
  Color? decorationColor,
  FontStyle? fontStyle,
  List<FontFeature>? fontFeatures,
  Color? backgroundColor,
}) {
  return TextStyle(
    fontFamily: 'JetBrainsMono',
    backgroundColor: backgroundColor,
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    decoration: decoration,
    decorationColor: decorationColor,
    fontStyle: fontStyle,
    fontFeatures: fontFeatures,
  );
}

/// Instrument Serif italic, the About page's editorial accent. The family
/// ships one weight, so [fontWeight] is accepted for call-site parity but not
/// applied (no faux bold); the style is always italic.
TextStyle serifFont({
  double? fontSize,
  FontWeight? fontWeight,
  FontStyle? fontStyle,
  Color? color,
  double? letterSpacing,
  double? height,
  TextDecoration? decoration,
  Color? decorationColor,
  TextDecorationStyle? decorationStyle,
}) {
  return TextStyle(
    fontFamily: 'InstrumentSerif',
    decoration: decoration,
    decorationColor: decorationColor,
    decorationStyle: decorationStyle,
    fontStyle: FontStyle.italic,
    fontSize: fontSize,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );
}

/// The M3 type scale (Kuber tokens.md §3): 13 roles, Inter, tabular figures.
TextTheme buildTextTheme(ColorScheme cs) {
  const tab = [FontFeature.tabularFigures()];
  TextStyle r(double size, double line, FontWeight w, double tracking,
          [Color? color]) =>
      localeFont(
        fontSize: size,
        fontWeight: w,
        letterSpacing: tracking,
        height: line / size,
        color: color ?? cs.onSurface,
        fontFeatures: tab,
      );
  return TextTheme(
    displayLarge: r(57, 64, FontWeight.w700, -0.25),
    displayMedium: r(45, 52, FontWeight.w700, 0),
    displaySmall: r(36, 44, FontWeight.w700, -0.5),
    headlineLarge: r(32, 40, FontWeight.w700, -0.5),
    headlineMedium: r(28, 36, FontWeight.w700, -0.25),
    headlineSmall: r(24, 32, FontWeight.w600, 0),
    titleLarge: r(22, 28, FontWeight.w600, -0.2),
    titleMedium: r(16, 24, FontWeight.w600, 0.1),
    titleSmall: r(14, 20, FontWeight.w600, 0.1),
    bodyLarge: r(16, 24, FontWeight.w400, 0),
    bodyMedium: r(14, 20, FontWeight.w400, 0),
    bodySmall: r(12, 16, FontWeight.w400, 0, cs.onSurfaceVariant),
    labelLarge: r(14, 20, FontWeight.w600, 0.1),
    labelMedium: r(12, 16, FontWeight.w600, 0.5),
    labelSmall: r(11, 16, FontWeight.w500, 0.5),
  );
}

/// Section header style: labelMedium, uppercase is applied by the caller,
/// 0.8 tracking, onSurfaceVariant.
TextStyle sectionHeaderStyle(BuildContext context) {
  final t = Theme.of(context);
  return t.textTheme.labelMedium!.copyWith(
    letterSpacing: 0.8,
    color: t.colorScheme.onSurfaceVariant,
  );
}

/// Display-only sentence case for labels written in all caps ("RUN CODE" ->
/// "Run code"). Mixed-case text passes through untouched.
String sentenceCase(String s) {
  if (s.isEmpty || s != s.toUpperCase()) return s;
  final lower = s.toLowerCase();
  return lower[0].toUpperCase() + lower.substring(1);
}
