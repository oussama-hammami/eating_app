import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/meal_entry.dart';
import 'quantity_dialog.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      title: Text(entry.foodName),
      subtitle: Text(
        l10n.mealEntrySubtitle(
          '${_formatAmount(entry.amount)} ${unitLabel(l10n, entry.unit)}',
          entry.calories.round(),
          entry.protein.toStringAsFixed(1),
          entry.carbs.toStringAsFixed(1),
          entry.fat.toStringAsFixed(1),
        ),
      ),
      onTap: onEdit,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}

String _formatAmount(double amount) {
  return amount == amount.roundToDouble()
      ? amount.toStringAsFixed(0)
      : amount.toString();
}
