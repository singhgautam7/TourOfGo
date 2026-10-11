import 'package:flutter/material.dart';

import '../utils/locale_font.dart';

// Tokens and theme ported from Kuber `core/theme/app_theme.dart` (the M3
// round-1 design system, tokens.md §1, §2, §8). Kuber names are kept so the
// two apps read the same.

/// Spacing: the 4/8 scale plus the layout metrics that are defined once.
abstract final class KuberSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Horizontal edge of every screen.
  static const double screenMargin = 20;

  /// Between sections.
  static const double sectionGap = 28;

  /// Section header to its content.
  static const double sectionHeaderGap = 8;

  /// Between stacked cards / tiles.
  static const double cardGap = 12;
  static const double cardPadding = 16;

  /// The one hero card per screen.
  static const double cardPaddingHero = 20;

  static const double listItem1 = 56;
  static const double listItem2 = 72;
  static const double listItem3 = 88;
  static const double listRowPadH = 16;
  static const double listRowPadV = 8;
  static const double tapTarget = 48;
}

/// Shape scale. Rounded, never squircle.
abstract final class KuberShape {
  static const double none = 0;

  /// Bar tops.
  static const double extraSmall = 4;

  /// Chips, tooltips, inline badges.
  static const double small = 8;

  /// Tiles, menu rows, inner tiles in cards.
  static const double medium = 12;

  /// Text fields, snackbar, nested containers, code blocks.
  static const double large = 16;

  /// Cards, grouped lists, menus.
  static const double largeIncreased = 20;

  /// Sheets (top), dialogs.
  static const double extraLarge = 28;

  /// Buttons, icon buttons, FAB, segmented, progress, badges.
  static const double full = 999;

  static const BorderRadius smallR = BorderRadius.all(Radius.circular(small));
  static const BorderRadius mediumR = BorderRadius.all(Radius.circular(medium));
  static const BorderRadius largeR = BorderRadius.all(Radius.circular(large));
  static const BorderRadius cardR =
      BorderRadius.all(Radius.circular(largeIncreased));
  static const BorderRadius sheetR =
      BorderRadius.vertical(top: Radius.circular(extraLarge));
  static const BorderRadius fullR = BorderRadius.all(Radius.circular(full));
}

/// Motion tokens (from Perch `Motion`, via Kuber).
abstract final class KuberMotion {
  static const Duration instant = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 220);
  static const Duration reducedFade = Duration(milliseconds: 90);

  /// Anything the finger caused.
  static const Curve spring = Curves.easeOutBack;

  /// Anything the system caused.
  static const Curve decelerate = Curves.easeOutCubic;

  static bool reduced(BuildContext context) {
    final mq = MediaQuery.of(context);
    return mq.disableAnimations || mq.accessibleNavigation;
  }

  static Duration of(BuildContext context, Duration full) =>
      reduced(context) ? reducedFade : full;
}

/// Go cyan, go.dev's brand colour, as the seed.
const _goCyan = Color(0xFF00ACD7);

/// Material's own tonal scheme for Go cyan (the vibrant variant): surfaces
/// carry a cool tint instead of plain white and grey, containers are pale
/// tones that always take dark text, and only filled elements (primary) are
/// deep cyan with white text. Fidelity was tried first; it makes
/// primaryContainer the raw seed, a bright cyan that read flushed and mixed
/// white and dark text on the same screen.
ColorScheme _scheme(Brightness b) {
  final scheme = ColorScheme.fromSeed(
    seedColor: _goCyan,
    brightness: b,
    dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
  );
  // Dark drops the page to true black, as Kuber does.
  return b == Brightness.dark
      ? scheme.copyWith(
          surface: const Color(0xFF000000),
          surfaceContainerLowest: const Color(0xFF000000),
        )
      : scheme;
}

class AppTheme {
  static ThemeData light() => _light;
  static ThemeData dark() => _dark;

  static final ThemeData _light = _build(_scheme(Brightness.light));
  static final ThemeData _dark = _build(_scheme(Brightness.dark));

  static ThemeData _build(ColorScheme cs) {
    final text = buildTextTheme(cs);
    const stadium = StadiumBorder();
    final labelLarge = text.labelLarge!;

    return ThemeData(
      useMaterial3: true,
      brightness: cs.brightness,
      colorScheme: cs,
      fontFamily: 'Inter',
      textTheme: text,
      splashFactory: InkSparkle.splashFactory,
      scaffoldBackgroundColor: cs.surface,
      canvasColor: cs.surface,
      cardTheme: CardThemeData(
        color: cs.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: KuberShape.cardR,
          side: BorderSide(color: cs.outlineVariant),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHigh,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: const OutlineInputBorder(
          borderRadius: KuberShape.largeR,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: KuberShape.largeR,
          borderSide: BorderSide.none,
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: KuberShape.largeR,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: KuberShape.largeR,
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: KuberShape.largeR,
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: KuberShape.largeR,
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        hintStyle: text.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
        labelStyle: text.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
        floatingLabelStyle: text.bodySmall!.copyWith(color: cs.primary),
        helperStyle: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
        counterStyle: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
        errorStyle: text.bodySmall!.copyWith(color: cs.error),
        prefixIconColor: cs.onSurfaceVariant,
        suffixIconColor: cs.onSurfaceVariant,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: cs.primary,
        selectionColor: cs.primary.withValues(alpha: 0.3),
        selectionHandleColor: cs.primary,
      ),
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cs.inverseSurface,
        contentTextStyle:
            text.bodyMedium!.copyWith(color: cs.onInverseSurface),
        actionTextColor: cs.inversePrimary,
        shape: const RoundedRectangleBorder(borderRadius: KuberShape.largeR),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: cs.secondaryContainer,
        disabledColor: cs.onSurface.withValues(alpha: 0.12),
        side: WidgetStateBorderSide.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? BorderSide.none
                : BorderSide(color: cs.outlineVariant)),
        checkmarkColor: cs.onSecondaryContainer,
        showCheckmark: true,
        labelStyle: labelLarge.copyWith(color: cs.onSurfaceVariant),
        secondaryLabelStyle:
            labelLarge.copyWith(color: cs.onSecondaryContainer),
        iconTheme: IconThemeData(color: cs.primary, size: 18),
        shape: const RoundedRectangleBorder(borderRadius: KuberShape.smallR),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        elevation: 0,
        pressElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surfaceContainerLow,
        modalBackgroundColor: cs.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        modalBarrierColor: cs.scrim.withValues(alpha: 0.32),
        shape: const RoundedRectangleBorder(borderRadius: KuberShape.sheetR),
        showDragHandle: false,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        barrierColor: cs.scrim.withValues(alpha: 0.32),
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(KuberShape.extraLarge)),
        ),
        titleTextStyle: text.headlineSmall!.copyWith(color: cs.onSurface),
        contentTextStyle:
            text.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: stadium,
          minimumSize: const Size(64, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          backgroundColor: cs.secondaryContainer,
          foregroundColor: cs.onSecondaryContainer,
          shape: stadium,
          minimumSize: const Size(64, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.onSurface,
          side: BorderSide(color: cs.outlineVariant),
          shape: stadium,
          minimumSize: const Size(64, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          shape: stadium,
          minimumSize: const Size(48, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          textStyle: labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(shape: const CircleBorder()),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const CircleBorder(),
      ),
      switchTheme: SwitchThemeData(
        thumbIcon: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? Icon(Icons.check_rounded, size: 16, color: cs.primary)
                : null),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: cs.primary,
        linearTrackColor: cs.secondaryContainer,
        circularTrackColor: Colors.transparent,
        // ignore: deprecated_member_use
        year2023: false,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: cs.primary,
        inactiveTrackColor: cs.secondaryContainer,
        thumbColor: cs.primary,
        // ignore: deprecated_member_use
        year2023: false,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: cs.onSurfaceVariant,
        minVerticalPadding: KuberSpace.listRowPadV,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: KuberSpace.listRowPadH),
        horizontalTitleGap: 16,
        titleTextStyle: text.titleMedium!.copyWith(color: cs.onSurface),
        subtitleTextStyle:
            text.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
        shape: const RoundedRectangleBorder(borderRadius: KuberShape.mediumR),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: cs.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        menuPadding: const EdgeInsets.all(KuberSpace.sm),
        textStyle: labelLarge.copyWith(color: cs.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: KuberShape.cardR,
          side: BorderSide(color: cs.outlineVariant),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: cs.inverseSurface,
          borderRadius: const BorderRadius.all(
              Radius.circular(KuberShape.extraSmall)),
        ),
        textStyle: text.bodySmall!.copyWith(color: cs.onInverseSurface),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}
