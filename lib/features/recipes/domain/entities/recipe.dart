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
}
