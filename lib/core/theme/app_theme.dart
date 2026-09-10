import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_palette.dart';

/// Centralized theme for "PlanA table".
///
/// Visual direction: "French Culinary Editorial" — warm linen as the neutral
/// base, terracotta as the one recognizable brand/action color, sage green
/// used for success/organic/Nutri-Score meaning, and slate for text. The
/// interface is deliberately quiet so that recipe photos and food provide
/// the color, not the chrome around them.
///
/// Do not read [AppPalette] hex values directly from widgets — use
/// `Theme.of(context).colorScheme` (and `context.semanticColors` for
/// success/warning/info) so the brand can be changed in one place.
class AppTheme {
  AppTheme._();

  static final ThemeData light = _build(
    brightness: Brightness.light,
    background: AppPalette.linen,
    colorScheme: const ColorScheme.light(
      primary: AppPalette.terracotta,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFFBE3DB), // faint terracotta tint
      onPrimaryContainer: AppPalette.terracotta,
      secondary: AppPalette.sage,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFE3EEE6), // faint sage tint
      onSecondaryContainer: AppPalette.sage,
      surface: AppPalette.ivory,
      onSurface: AppPalette.slate,
      onSurfaceVariant: AppPalette.mauveGray,
      surfaceContainerHighest: Color(0xFFF3EEE4),
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
      primary: AppPalette.darkTerracotta,
      onPrimary: AppPalette.darkBackground,
      primaryContainer: Color(0xFF4A342C), // dark terracotta tint
      onPrimaryContainer: AppPalette.darkTerracotta,
      secondary: AppPalette.darkSage,
      onSecondary: AppPalette.darkBackground,
      secondaryContainer: Color(0xFF2E3B32), // dark sage tint
      onSecondaryContainer: AppPalette.darkSage,
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
    // Playfair Display (an editorial serif) for headings/dish titles; Inter
    // (a clean, highly-legible sans) for body/ingredients/data.
    final baseTextTheme = GoogleFonts.interTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ).apply(bodyColor: colorScheme.onSurface, displayColor: colorScheme.onSurface);

    TextStyle heading({required double fontSize, required FontWeight fontWeight}) =>
        GoogleFonts.playfairDisplay(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: colorScheme.onSurface,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      extensions: [semanticColors],
      textTheme: baseTextTheme.copyWith(
        titleLarge: heading(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: heading(fontSize: 18, fontWeight: FontWeight.w700),
        headlineSmall: heading(fontSize: 24, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: heading(fontSize: 22, fontWeight: FontWeight.w600)
            .copyWith(letterSpacing: 0.5),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 2,
        shadowColor: const Color(0x0D000000),
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.4),
          elevation: 2,
          shadowColor: colorScheme.primary.withValues(alpha: 0.35),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.secondary,
          backgroundColor: colorScheme.secondary.withValues(alpha: 0.1),
          side: BorderSide(color: colorScheme.secondary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
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
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: heading(fontSize: 20, fontWeight: FontWeight.w700),
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
    );
  }
}
