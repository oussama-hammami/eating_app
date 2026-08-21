import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/stat_chip.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../nutrition/domain/usecases/food_matcher.dart';
import '../../../nutrition/presentation/providers/food_search_provider.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/usecases/community_recipes.dart';
import '../../domain/usecases/compute_nutrition.dart';

/// Read-only browse screen for community-contributed recipes. Nutrition is
/// computed on load (not hardcoded) by running each ingredient through the
/// same food-matching + calculation pipeline the add-recipe dialog uses.
class CommunityTab extends ConsumerStatefulWidget {
  const CommunityTab({super.key});

  @override
  ConsumerState<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends ConsumerState<CommunityTab> {
  List<Recipe>? _recipes;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final foodRepository = ref.read(foodRepositoryProvider);
    final matcher = FoodMatcher(foodRepository);
    final computed = <Recipe>[];
    for (final recipe in communityBreakfastRecipes()) {
      computed.add(await computeNutrition(foodRepository, matcher, recipe));
    }
    if (!mounted) return;
    setState(() => _recipes = computed);
  }

  void _showIngredientNutrition(Ingredient ingredient) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          ingredient.quantity.isEmpty
              ? ingredient.name
              : '${ingredient.name} (${ingredient.quantity})',
        ),
        content: ingredient.calories != null &&
                ingredient.protein != null &&
                ingredient.carbs != null &&
                ingredient.fat != null &&
                ingredient.fiber != null
            ? Text(
                '${l10n.caloriesKcalChip(ingredient.calories!.round())} • '
                '${l10n.proteinGChip(ingredient.protein!.round())} • '
                '${l10n.carbsGChip(ingredient.carbs!.round())} • '
                '${l10n.fatGChip(ingredient.fat!.round())} • '
                '${l10n.fiberGChip(ingredient.fiber!.round())}',
              )
            : Text(
                ingredient.needsConfirmation
                    ? l10n.ingredientNeedsConfirmation
                    : l10n.ingredientNutritionUnknown,
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _openRecipeDetailsDialog(Recipe recipe) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(recipe.name),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatChip(
                        icon: recipe.mealType.icon,
                        label: recipe.mealType.label(l10n),
                        color: AppPalette.tealDark,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.recipeStatsLine(recipe.calories, recipe.protein, recipe.portions),
                      ),
                      const SizedBox(height: 16),
                      if (recipe.ingredients.isNotEmpty) ...[
                        Text(
                          l10n.ingredients,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...recipe.ingredients.asMap().entries.map((entry) {
                          final i = entry.key;
                          final ingredient = entry.value;
                          return GestureDetector(
                            onLongPress: () => _showIngredientNutrition(ingredient),
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                ingredient.quantity.isEmpty
                                    ? ingredient.name
                                    : '${ingredient.name} — ${ingredient.quantity}',
                              ),
                              value: recipe.checkedIngredients[i],
                              onChanged: (checked) {
                                setDialogState(() {
                                  recipe.checkedIngredients[i] = checked ?? false;
                                });
                              },
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.close),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recipes = _recipes;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.communityTitle)),
      body: recipes == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.communityLoadingNutrition),
                ],
              ),
            )
          : recipes.isEmpty
              ? EmptyState(icon: Icons.groups_outlined, message: l10n.communityEmpty)
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(
                          recipe.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Wrap(
                            spacing: 8,
                            children: [
                              StatChip(
                                icon: recipe.mealType.icon,
                                label: recipe.mealType.label(l10n),
                                color: AppPalette.tealDark,
                              ),
                              StatChip(
                                icon: Icons.local_fire_department,
                                label: l10n.caloriesKcalChip(recipe.calories),
                                color: AppPalette.orangeDeep,
                              ),
                              StatChip(
                                icon: Icons.fitness_center,
                                label: l10n.proteinGChip(recipe.protein),
                                color: AppPalette.tealDark,
                              ),
                              StatChip(
                                icon: Icons.people_outline,
                                label: l10n.portionsChip(recipe.portions),
                                color: AppPalette.ink,
                              ),
                            ],
                          ),
                        ),
                        onTap: () => _openRecipeDetailsDialog(recipe),
                      ),
                    );
                  },
                ),
    );
  }
}
