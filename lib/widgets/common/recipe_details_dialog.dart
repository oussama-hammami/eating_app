import 'package:flutter/material.dart';

import '../../features/recipes/domain/entities/recipe.dart';
import '../../features/recipes/presentation/widgets/recipe_photo.dart';
import '../../l10n/app_localizations.dart';

/// Read-only recipe details popup — photo, meal type, calories/protein/
/// portions, ingredients, and preparation. Used wherever a recipe needs a
/// quick "what is this meal" view without going into full edit mode (e.g.
/// tapping a recipe card in the Weekly Planner).
class RecipeDetailsDialog extends StatelessWidget {
  const RecipeDetailsDialog({super.key, required this.recipe});

  final Recipe recipe;

  static void show(BuildContext context, Recipe recipe) {
    showDialog<void>(
      context: context,
      builder: (_) => RecipeDetailsDialog(recipe: recipe),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(recipe.name, style: Theme.of(context).textTheme.titleLarge),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: RecipePhoto(
                  path: recipe.photoPath,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Chip(
                avatar: Icon(
                  recipe.mealType.icon,
                  size: 18,
                  color: colorScheme.primary,
                ),
                label: Text(recipe.mealType.label(l10n)),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.recipeStatsLine(
                  recipe.calories,
                  recipe.protein,
                  recipe.portions,
                ),
              ),
              const SizedBox(height: 16),
              if (recipe.ingredients.isNotEmpty) ...[
                Text(
                  l10n.ingredients,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...recipe.ingredients.map(
                  (ingredient) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      ingredient.quantity.isEmpty
                          ? '• ${ingredient.name}'
                          : '• ${ingredient.name} — ${ingredient.quantity}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (recipe.description.isNotEmpty) ...[
                Text(
                  l10n.preparation,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(recipe.description),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}
