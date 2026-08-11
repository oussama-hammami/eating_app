import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/food.dart';

class FoodSuggestionTile extends StatelessWidget {
  const FoodSuggestionTile({super.key, required this.food, required this.onTap});

  final Food food;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final kcal = food.caloriesKcal100g;
    return ListTile(
      title: Text(food.displayName(languageCode)),
      subtitle: Text(kcal == null ? l10n.perHundredGrams : l10n.kcalPer100g(kcal.round())),
      onTap: onTap,
    );
  }
}
