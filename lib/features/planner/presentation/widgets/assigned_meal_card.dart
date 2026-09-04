import 'package:flutter/material.dart';

import '../../../../core/widgets/stat_chip.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../../recipes/presentation/widgets/recipe_photo.dart';
import '../../domain/entities/meal_plan_entry.dart';

/// One recipe assigned to a meal slot — a photo thumbnail, name, and scaled
/// macro chips, with "replace" and "remove" actions.
class AssignedMealCard extends StatelessWidget {
  const AssignedMealCard({
    super.key,
    required this.entry,
    required this.recipe,
    required this.onRemove,
    required this.onReplace,
  });

  final MealPlanEntry entry;
  final Recipe? recipe;
  final VoidCallback onRemove;
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final recipe = this.recipe;
    final factor = recipe == null || recipe.portions <= 0 ? 0.0 : entry.servings / recipe.portions;
    final calories = recipe == null ? 0 : (recipe.calories * factor).round();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: RecipePhoto(path: recipe?.photoPath, width: 48, height: 48, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe?.name ?? entry.recipeId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      StatChip(
                        icon: Icons.local_fire_department,
                        label: l10n.caloriesKcalChip(calories),
                        color: colorScheme.secondary,
                      ),
                      StatChip(
                        icon: Icons.people_outline,
                        label: l10n.portionsChip(entry.servings),
                        color: colorScheme.onSurface,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.swap_horiz, size: 18),
                  tooltip: l10n.plannerReplaceMeal,
                  onPressed: onReplace,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: l10n.plannerRemoveMeal,
                  onPressed: onRemove,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
