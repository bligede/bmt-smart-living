import 'package:flutter/material.dart';
import '../core/tokens.dart';

ThemeData bmtTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final text = dark ? BmtColors.onDark : BmtColors.ink;
  final secondary = dark ? BmtColors.mutedDark : BmtColors.secondary;
  final accent = dark ? BmtColors.green300 : BmtColors.green700;
  final surface = dark ? BmtColors.ink950 : Colors.white;
  TextStyle style(
    double size,
    double height,
    FontWeight weight, {
    Color? color,
  }) => TextStyle(
    fontFamily: 'Inter',
    fontSize: size,
    height: height / size,
    fontWeight: weight,
    color: color ?? text,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  return ThemeData(
    brightness: brightness,
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: surface,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: dark ? BmtColors.ink950 : Colors.white,
      secondary: accent,
      onSecondary: dark ? BmtColors.ink950 : Colors.white,
      error: dark ? BmtColors.dangerDark : BmtColors.danger,
      onError: dark ? BmtColors.ink950 : Colors.white,
      surface: surface,
      onSurface: text,
      outline: dark ? BmtColors.ink700 : BmtColors.slate200,
      surfaceContainerHighest: dark ? BmtColors.anchor : BmtColors.slate50,
    ),
    textTheme: TextTheme(
      displaySmall: style(40, 44, FontWeight.w700),
      headlineMedium: style(28, 34, FontWeight.w700),
      titleLarge: style(20, 26, FontWeight.w700),
      titleMedium: style(15, 22, FontWeight.w600),
      bodyLarge: style(15, 22, FontWeight.w400),
      bodyMedium: style(13, 18, FontWeight.w400),
      bodySmall: style(12, 16, FontWeight.w400, color: secondary),
      labelLarge: style(15, 22, FontWeight.w600),
      labelMedium: style(13, 18, FontWeight.w600),
      labelSmall: style(12, 16, FontWeight.w600),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: BmtColors.anchor,
      foregroundColor: BmtColors.onDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    sliderTheme: const SliderThemeData(trackHeight: 4),
    navigationBarTheme: NavigationBarThemeData(
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? accent : secondary,
          size: 24,
        ),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: dark ? BmtColors.ink700 : BmtColors.slate200,
      space: 1,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: BmtColors.anchor,
      contentTextStyle: TextStyle(fontFamily: 'Inter', color: BmtColors.onDark),
    ),
  );
}
