import 'ingredient.dart';
import 'meal_type.dart';

class Recipe {
  Recipe({
    required this.name,
    required this.calories,
    required this.protein,
    required this.portions,
    required this.ingredients,
    required this.description,
    required this.mealType,
    this.photoPath,
    this.carbs,
    this.fat,
  }) : checkedIngredients = List.filled(ingredients.length, false);

  final String name;
  final int calories;
  final int protein;
  final int portions;
  final List<Ingredient> ingredients;
  final String description;
  final MealType mealType;
  final String? photoPath;
  final List<bool> checkedIngredients;

  /// Recipe-level carbs/fat totals, when known upfront (e.g. from a curated
  /// dataset) rather than derived by summing ingredient-level nutrition.
  /// Null means "unknown" — callers that need a total should fall back to
  /// summing [ingredients] themselves (see recipeCarbsTotal/recipeFatTotal).
  final int? carbs;
  final int? fat;

  /// A fresh copy with its own [checkedIngredients] state — for adding a
  /// recipe (e.g. from Community) into another list without the two
  /// instances sharing (and fighting over) the same mutable checklist.
  Recipe copy() => Recipe(
        name: name,
        calories: calories,
        protein: protein,
        portions: portions,
        ingredients: ingredients,
        description: description,
        mealType: mealType,
        photoPath: photoPath,
        carbs: carbs,
        fat: fat,
      );
}
