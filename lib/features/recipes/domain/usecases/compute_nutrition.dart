import 'package:flutter/foundation.dart';

import '../../../../core/units/legacy_quantity_parser.dart';
import '../../../nutrition/domain/usecases/food_matcher.dart';
import '../../../nutrition/domain/usecases/nutrition_calculator.dart';
import '../../../nutrition/domain/repositories/food_repository.dart';
import '../entities/ingredient.dart';
import '../entities/recipe.dart';

/// Computes a [Recipe]'s ingredient-level and total nutrition by running
/// each ingredient through the full audited pipeline: concept-level food
/// matching ([FoodMatcher]), then unit conversion, then per-100g scaling
/// ([calculateIngredientNutrition]) — the same pipeline the add-recipe
/// dialog uses when a user picks a food and types a quantity. Every
/// ingredient's full audit trail is printed via [debugPrint] so a wrong or
/// missing value can always be traced back to exactly why.
Future<Recipe> computeNutrition(
  FoodRepository foodRepository,
  FoodMatcher matcher,
  Recipe recipe,
) async {
  final debugRows = <IngredientCalculationDebug>[];

  for (final ingredient in recipe.ingredients) {
    if (ingredient.name.trim().isEmpty) {
      continue;
    }
    final (amountText, unit) = parseLegacyQuantity(ingredient.quantity);
    final amount = double.tryParse(amountText);
    debugRows.add(
      await calculateIngredientNutrition(
        repository: foodRepository,
        matcher: matcher,
        ingredientName: ingredient.name,
        amount: amount,
        unit: unit,
      ),
    );
  }

  debugPrint('--- nutrition audit: ${recipe.name} ---');
  for (final row in debugRows) {
    debugPrint(row.toDebugRow());
  }

  final totals = computeRecipeTotals(debugRows, servings: recipe.portions);
  if (totals.incompleteIngredients.isNotEmpty) {
    debugPrint(
      '${recipe.name}: totals are a partial sum — '
      'no confident nutrition for: ${totals.incompleteIngredients.join(', ')}',
    );
  }

  final computedIngredients = debugRows
      .map(
        (row) => Ingredient(
          name: row.ingredientEntered,
          quantity: row.amount == null ? '' : '${row.amount} ${row.unit.id}',
          calories: row.calories,
          protein: row.protein,
          carbs: row.carbs,
          fat: row.fat,
          fiber: row.fiber,
          matchConfidence: row.matchConfidence,
          needsConfirmation: row.needsConfirmation,
        ),
      )
      .toList();

  return Recipe(
    name: recipe.name,
    calories: totals.totalCalories.round(),
    protein: totals.totalProtein.round(),
    portions: recipe.portions,
    ingredients: computedIngredients,
    description: recipe.description,
    mealType: recipe.mealType,
    photoPath: recipe.photoPath,
  );
}
