import 'package:flutter/material.dart';

import '../../domain/entities/meal_entry.dart';

class MealEntryTile extends StatelessWidget {
  const MealEntryTile({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final MealEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entry.foodName),
      subtitle: Text(
        '${entry.grams.toStringAsFixed(0)} g · ${entry.calories.round()} kcal · '
        'P ${entry.protein.toStringAsFixed(1)}g · '
        'C ${entry.carbs.toStringAsFixed(1)}g · '
        'F ${entry.fat.toStringAsFixed(1)}g',
      ),
      onTap: onEdit,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}
