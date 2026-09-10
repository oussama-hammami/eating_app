import 'package:flutter/material.dart';

/// Raw brand hex values for "PlanA table".
///
/// Visual direction: "French Culinary Editorial" — warm linen background,
/// terracotta as the one recognizable brand/action color, sage green as the
/// secondary accent (success, Nutri-Score A/B, organic), and slate for text.
/// Cards stay pure white so food photography and dish titles read as the
/// color, not the chrome around them.
///
/// Widgets should NOT reference this class directly — consume colors via
/// `Theme.of(context).colorScheme` and `context.semanticColors` instead
/// (see `app_theme.dart` / `app_colors.dart`). This file only exists to
/// centralize the hex source values used to build the light/dark themes.
class AppPalette {
  AppPalette._();

  // --- Light mode ---
  static const terracotta = Color(0xFFD95D39); // primary
  static const sage = Color(0xFF5B8A68); // secondary
  static const linen = Color(0xFFFDFBF7); // background
  static const ivory = Color(0xFFFFFFFF); // surface (cards, sheets, dialogs)
  static const slate = Color(0xFF2A2D34); // primary text
  static const mauveGray = Color(0xFF757A82); // secondary text
  static const divider = Color(0xFFE9E3D8); // borders / dividers

  /// Calories stat chips/icons everywhere (recipe cards, meal cards, planner
  /// daily totals) — same color in light and dark so calories stays
  /// visually distinct from the sage-colored protein/success stats.
  static const calories = Color(0xFFFF7F50);

  /// Meal slot marker pill background (Petit-déjeuner/Déjeuner/Dîner/En-cas)
  /// in the weekly planner.
  static const mealType = Color(0xFFFFDDB0);
  static const onMealType = Color(0xFF6B4423);

  // --- Dark mode ---
  static const darkBackground = Color(0xFF1C1D20);
  static const darkSurface = Color(0xFF25272B);
  static const darkElevated = Color(0xFF303338);
  static const darkTerracotta = Color(0xFFE58465); // primary
  static const darkSage = Color(0xFF83B08F); // secondary
  static const darkText = Color(0xFFF6F3EC); // primary text
  static const darkMutedText = Color(0xFFB8BCC2); // secondary text
  static const darkDivider = Color(0xFF3B3E44);

  // --- Semantic (shared meaning, tuned per-mode for contrast) ---
  static const successLight = sage;
  static const warningLight = Color(0xFFD49A4A);
  static const errorLight = Color(0xFFB85C62);
  static const infoLight = Color(0xFF6879A6);

  static const successDark = darkSage;
  static const warningDark = Color(0xFFE3B36F);
  static const errorDark = Color(0xFFD17B81);
  static const infoDark = Color(0xFF8C9BC7);
}
