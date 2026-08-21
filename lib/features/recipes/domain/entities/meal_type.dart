import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

enum MealType {
  breakfast(Icons.free_breakfast_outlined),
  lunch(Icons.lunch_dining_outlined),
  dinner(Icons.dinner_dining_outlined),
  snack(Icons.cookie_outlined),
  drink(Icons.local_bar_outlined);

  const MealType(this.icon);

  final IconData icon;

  String label(AppLocalizations l10n) {
    switch (this) {
      case MealType.breakfast:
        return l10n.mealTypeBreakfast;
      case MealType.lunch:
        return l10n.mealTypeLunch;
      case MealType.dinner:
        return l10n.mealTypeDinner;
      case MealType.snack:
        return l10n.mealTypeSnack;
      case MealType.drink:
        return l10n.mealTypeDrink;
    }
  }
}
