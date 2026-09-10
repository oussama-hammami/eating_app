import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../../recipes/presentation/widgets/recipe_photo.dart';
import '../../../../widgets/common/recipe_details_dialog.dart';
import '../../domain/entities/meal_plan_entry.dart';

/// One recipe assigned to a meal slot — a compact, shrink-wrapped card: a
/// photo thumbnail, name, bare icon+value calorie/protein indicators, an
/// inline servings stepper (-/+), and "replace"/"remove" actions. Tapping
/// the card (outside the action buttons) opens a read-only details popup.
class AssignedMealCard extends StatelessWidget {
  const AssignedMealCard({
    super.key,
    required this.entry,
    required this.recipe,
    required this.onRemove,
    required this.onReplace,
    required this.onAdjustServings,
  });

  final MealPlanEntry entry;
  final Recipe? recipe;
  final VoidCallback onRemove;
  final VoidCallback onReplace;

  /// Called with -1 or +1 to nudge the entry's servings.
  final void Function(int delta) onAdjustServings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recipe = this.recipe;
    final factor = recipe == null || recipe.portions <= 0
        ? 0.0
        : entry.servings / recipe.portions;
    final calories = recipe == null ? 0 : (recipe.calories * factor).round();
    final protein = recipe == null ? 0 : (recipe.protein * factor).round();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: recipe == null
            ? null
            : () => RecipeDetailsDialog.show(context, recipe),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: RecipePhoto(
                  path: recipe?.photoPath,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      recipe?.name ?? entry.recipeId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _IconValue(
                          icon: Icons.local_fire_department,
                          value: calories,
                          color: AppPalette.calories,
                        ),
                        const SizedBox(width: 10),
                        _IconValue(
                          icon: Icons.bolt,
                          value: protein,
                          color: const Color(0xFF2A835F),
                        ),
                        const SizedBox(width: 10),
                        _ServingsStepper(
                          servings: entry.servings,
                          onAdjust: onAdjustServings,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.swap_horiz, size: 18),
                tooltip: l10n.plannerReplaceMeal,
                onPressed: onReplace,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                tooltip: l10n.plannerRemoveMeal,
                onPressed: onRemove,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A bare icon + numeric value on a tinted color box, no unit text — e.g.
/// 🔥500 instead of a full "500 kcal" chip.
class _IconValue extends StatelessWidget {
  const _IconValue({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 3),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServingsStepper extends StatelessWidget {
  const _ServingsStepper({required this.servings, required this.onAdjust});

  final int servings;
  final void Function(int delta) onAdjust;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepperButton(
            context,
            icon: Icons.remove,
            onTap: () => onAdjust(-1),
          ),
          SizedBox(
            width: 20,
            child: Text(
              '$servings',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          _stepperButton(context, icon: Icons.add, onTap: () => onAdjust(1)),
        ],
      ),
    );
  }

  Widget _stepperButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 14, color: colorScheme.primary),
      ),
    );
  }
}
