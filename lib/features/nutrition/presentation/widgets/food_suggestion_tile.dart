import 'package:flutter/material.dart';

import '../../domain/entities/food.dart';

class FoodSuggestionTile extends StatelessWidget {
  const FoodSuggestionTile({super.key, required this.food, required this.onTap});

  final Food food;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kcal = food.caloriesKcal100g;
    return ListTile(
      title: Text(food.foodName),
      subtitle: Text(kcal == null ? 'per 100g' : '${kcal.round()} kcal / 100g'),
      onTap: onTap,
    );
  }
}
