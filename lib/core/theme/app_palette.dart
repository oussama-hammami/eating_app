import 'package:flutter/material.dart';

/// Raw brand hex values for "My Food This Week".
///
/// These are the source-of-truth colors for the app's visual identity:
/// deep plum + warm apricot on a warm-cream/ivory neutral base, designed to
/// stay out of the way of food photography rather than compete with it.
///
/// Widgets should NOT reference this class directly — consume colors via
/// `Theme.of(context).colorScheme` and `context.semanticColors` instead
/// (see `app_theme.dart` / `app_colors.dart`). This file only exists to
/// centralize the hex source values used to build the light/dark themes.
class AppPalette {
  AppPalette._();

  // --- Light mode ---
  static const plum = Color(0xFF542A4A); // primary
  static const apricot = Color(0xFFF2A65A); // secondary
  static const cream = Color(0xFFFAF7F2); // background
  static const ivory = Color(0xFFFFFFFF); // surface (cards, sheets, dialogs)
  static const charcoal = Color(0xFF29252A); // primary text
  static const mauveGray = Color(0xFF756B73); // secondary text
  static const divider = Color(0xFFE6DFE4); // borders / dividers

  // --- Dark mode ---
  static const darkBackground = Color(0xFF1D191D);
  static const darkSurface = Color(0xFF272127);
  static const darkElevated = Color(0xFF312A31);
  static const darkPlum = Color(0xFFC47FAE); // primary
  static const darkApricot = Color(0xFFF2B978); // secondary
  static const darkText = Color(0xFFF7F2F5); // primary text
  static const darkMutedText = Color(0xFFBDB2BA); // secondary text
  static const darkDivider = Color(0xFF413841);

  // --- Semantic (shared meaning, tuned per-mode for contrast) ---
  static const successLight = Color(0xFF5F8068);
  static const warningLight = Color(0xFFD49A4A);
  static const errorLight = Color(0xFFB85C62);
  static const infoLight = Color(0xFF6879A6);

  static const successDark = Color(0xFF80A187);
  static const warningDark = Color(0xFFE3B36F);
  static const errorDark = Color(0xFFD17B81);
  static const infoDark = Color(0xFF8C9BC7);
}
