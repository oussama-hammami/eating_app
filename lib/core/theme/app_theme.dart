import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';

/// Centralized theme for "My Food This Week".
///
/// Visual direction: modern, minimal, warm — deep plum as the one
/// recognizable brand color, warm apricot used sparingly as an accent, and a
/// calm cream/ivory neutral base everywhere else (roughly 80% neutral / 15%
/// primary / 5% accent). The interface is deliberately quiet so that recipe
/// photos and food provide the color, not the chrome around them.
///
/// Do not read [AppPalette] hex values directly from widgets — use
/// `Theme.of(context).colorScheme` (and `context.semanticColors` for
/// success/warning/info) so the brand can be changed in one place.
class AppTheme {
  AppTheme._();

  static final ThemeData light = _build(
    brightness: Brightness.light,
    background: AppPalette.cream,
    colorScheme: const ColorScheme.light(
      primary: AppPalette.plum,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFEFE1EA), // faint plum tint
      onPrimaryContainer: AppPalette.plum,
      secondary: AppPalette.apricot,
      onSecondary: AppPalette.charcoal,
      secondaryContainer: Color(0xFFFDEBD8), // faint apricot tint
      onSecondaryContainer: AppPalette.charcoal,
      surface: AppPalette.ivory,
      onSurface: AppPalette.charcoal,
      onSurfaceVariant: AppPalette.mauveGray,
      surfaceContainerHighest: Color(0xFFF3EEEB),
      outline: AppPalette.divider,
      outlineVariant: AppPalette.divider,
      error: AppPalette.errorLight,
      onError: Colors.white,
    ),
    semanticColors: AppSemanticColors.light,
  );

  static final ThemeData dark = _build(
    brightness: Brightness.dark,
    background: AppPalette.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppPalette.darkPlum,
      onPrimary: AppPalette.darkBackground,
      primaryContainer: Color(0xFF473140), // dark plum tint
      onPrimaryContainer: AppPalette.darkPlum,
      secondary: AppPalette.darkApricot,
      onSecondary: AppPalette.darkBackground,
      secondaryContainer: Color(0xFF453723), // dark apricot tint
      onSecondaryContainer: AppPalette.darkApricot,
      surface: AppPalette.darkSurface,
      onSurface: AppPalette.darkText,
      onSurfaceVariant: AppPalette.darkMutedText,
      surfaceContainerHighest: AppPalette.darkElevated,
      outline: AppPalette.darkDivider,
      outlineVariant: AppPalette.darkDivider,
      error: AppPalette.errorDark,
      onError: AppPalette.darkBackground,
    ),
    semanticColors: AppSemanticColors.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required ColorScheme colorScheme,
    required AppSemanticColors semanticColors,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Georgia',
      extensions: [semanticColors],
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surface;
        }),
        checkColor: WidgetStatePropertyAll(colorScheme.onPrimary),
        side: BorderSide(color: colorScheme.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurface),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle:
            TextStyle(color: colorScheme.onSurface, fontSize: 15),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        elevation: 8,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: colorScheme.onSurface),
        bodyMedium: TextStyle(color: colorScheme.onSurface),
        titleMedium: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
