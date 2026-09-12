import 'package:flutter/material.dart';

/// EstheBook design tokens — minimalist, luxurious, clean.
///
/// Palette: soft blush pink, sage green, cream white, and soft gold accents.
class EbColors {
  const EbColors._();

  // Brand palette.
  static const Color blush = Color(0xFFF7E8EA);
  static const Color blushDeep = Color(0xFFE8C4CB);
  static const Color sage = Color(0xFFA8BCA1);
  static const Color sageDeep = Color(0xFF7C9574);
  static const Color cream = Color(0xFFFDFBF7);
  static const Color gold = Color(0xFFC9A96A);
  static const Color goldDeep = Color(0xFFB08D4E);

  // Text.
  static const Color ink = Color(0xFF3E3232);
  static const Color inkSoft = Color(0xFF6E6060);
  static const Color onBlush = Color(0xFF5C4A4D);

  // Surfaces.
  static const Color surface = cream;
  static const Color card = Colors.white;
  static const Color divider = Color(0xFFF1E8E4);

  // Semantic.
  static const Color success = Color(0xFF7C9574);
  static const Color warning = Color(0xFFC9A96A);
  static const Color error = Color(0xFFC0605E);
  static const Color info = Color(0xFF7B93A8);

  static const Color shimmerBase = Color(0xFFF3ECE9);
  static const Color shimmerHighlight = Color(0xFFFAF6F3);
}

/// Typography — elegant serif headings, clean sans-serif body.
class EbTextStyles {
  const EbTextStyles._();

  // Note: Custom fonts (PlayfairDisplay, Inter) are optional.
  // When not included, system fonts provide fallback.
  static const String serifFamily = 'Georgia, serif';
  static const String sansFamily = 'system-ui, -apple-system, sans-serif';

  static const TextStyle h1 = TextStyle(
    fontFamily: serifFamily,
    fontSize: 30,
    height: 1.15,
    fontWeight: FontWeight.w700,
    color: EbColors.ink,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: serifFamily,
    fontSize: 24,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: EbColors.ink,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: serifFamily,
    fontSize: 19,
    height: 1.25,
    fontWeight: FontWeight.w600,
    color: EbColors.ink,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: sansFamily,
    fontSize: 15,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: EbColors.inkSoft,
  );

  static const TextStyle body = TextStyle(
    fontFamily: sansFamily,
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: EbColors.ink,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: sansFamily,
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w600,
    color: EbColors.ink,
  );

  static const TextStyle label = TextStyle(
    fontFamily: sansFamily,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: EbColors.inkSoft,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: sansFamily,
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
    color: EbColors.goldDeep,
  );

  static const TextStyle price = TextStyle(
    fontFamily: sansFamily,
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: EbColors.sageDeep,
  );
}

/// Spacing, radius, and shadow tokens shared across the app.
class EbSpacing {
  const EbSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double page = 20;
}

class EbRadius {
  const EbRadius._();

  static const double card = 16;
  static const double chip = 12;
  static const double button = 14;
  static const double sheet = 24;
}

class EbShadows {
  const EbShadows._();

  static List<BoxShadow> get soft => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get raised => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];
}

/// Builds the [ThemeData] used across EstheBook.
ThemeData buildEbTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: EbColors.sageDeep,
      onPrimary: Colors.white,
      secondary: EbColors.gold,
      onSecondary: Colors.white,
      tertiary: EbColors.blushDeep,
      surface: EbColors.surface,
      onSurface: EbColors.ink,
      surfaceContainerHighest: EbColors.blush,
      onSurfaceVariant: EbColors.inkSoft,
      error: EbColors.error,
      outline: Color(0xFFD9CCC6),
    ),
    scaffoldBackgroundColor: EbColors.surface,
    splashFactory: InkSparkle.splashFactory,
  );

  return base.copyWith(
    textTheme: const TextTheme(
      displayLarge: EbTextStyles.h1,
      displayMedium: EbTextStyles.h2,
      displaySmall: EbTextStyles.h3,
      headlineMedium: EbTextStyles.h2,
      headlineSmall: EbTextStyles.h3,
      titleLarge: EbTextStyles.h3,
      titleMedium: EbTextStyles.bodyStrong,
      titleSmall: EbTextStyles.subtitle,
      bodyLarge: EbTextStyles.body,
      bodyMedium: EbTextStyles.body,
      bodySmall: EbTextStyles.label,
      labelLarge: EbTextStyles.bodyStrong,
      labelMedium: EbTextStyles.label,
      labelSmall: EbTextStyles.overline,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: EbColors.surface,
      foregroundColor: EbColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: EbTextStyles.h3,
    ),
    cardTheme: CardThemeData(
      color: EbColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(EbRadius.card),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: EbColors.divider,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: EbSpacing.lg,
        vertical: EbSpacing.md,
      ),
      hintStyle: EbTextStyles.body.copyWith(color: const Color(0xFFB9A9A9)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(EbRadius.chip),
        borderSide: const BorderSide(color: EbColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(EbRadius.chip),
        borderSide: const BorderSide(color: EbColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(EbRadius.chip),
        borderSide: const BorderSide(color: EbColors.sageDeep, width: 1.4),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: EbColors.ink,
        foregroundColor: Colors.white,
        textStyle: EbTextStyles.bodyStrong,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EbRadius.button),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: EbSpacing.xl,
          vertical: EbSpacing.lg,
        ),
        minimumSize: const Size(64, 52),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: EbColors.ink,
        textStyle: EbTextStyles.bodyStrong,
        side: const BorderSide(color: EbColors.blushDeep),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EbRadius.button),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: EbSpacing.xl,
          vertical: EbSpacing.lg,
        ),
        minimumSize: const Size(64, 52),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: EbColors.sageDeep,
        textStyle: EbTextStyles.bodyStrong,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: EbColors.sage,
      checkmarkColor: Colors.white,
      side: const BorderSide(color: EbColors.divider),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(EbRadius.chip),
      ),
      labelStyle: EbTextStyles.label.copyWith(color: EbColors.ink),
      padding: const EdgeInsets.symmetric(
        horizontal: EbSpacing.md,
        vertical: EbSpacing.sm,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: EbColors.blush,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return EbTextStyles.label.copyWith(color: EbColors.sageDeep);
        }
        return EbTextStyles.label.copyWith(color: EbColors.inkSoft);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: EbColors.ink, size: 24);
        }
        return const IconThemeData(color: EbColors.inkSoft, size: 24);
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: EbColors.ink,
      contentTextStyle: EbTextStyles.body.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(EbRadius.chip),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: EbColors.card,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: EbColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(EbRadius.sheet)),
      ),
      showDragHandle: true,
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return EbColors.sageDeep;
        }
        return const Color(0xFFD9CCC6);
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: EbColors.sageDeep,
      linearTrackColor: EbColors.blush,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
      },
    ),
  );
}
