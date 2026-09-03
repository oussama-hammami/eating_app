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
  List<bool> checkedIngredients;

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

  Map<String, dynamic> toJson() => {
        'name': name,
        'calories': calories,
        'protein': protein,
        'portions': portions,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'description': description,
        'mealType': mealType.name,
        'photoPath': photoPath,
        'carbs': carbs,
        'fat': fat,
        'checkedIngredients': checkedIngredients,
      };

  factory Recipe.fromJson(Map<String, dynamic> json) => _fromJson(
        json,
        // A shared recipe's photo path points to the sender's local
        // filesystem, so it can't resolve on the receiving device.
        photoPath: null,
      );

  /// Like [fromJson], but keeps [photoPath] — for recipes persisted and
  /// reloaded on the same device, where the local path is still valid.
  factory Recipe.fromLocalJson(Map<String, dynamic> json) =>
      _fromJson(json, photoPath: json['photoPath'] as String?);

  static Recipe _fromJson(Map<String, dynamic> json, {required String? photoPath}) {
    final recipe = Recipe(
      name: json['name'] as String,
      calories: json['calories'] as int,
      protein: json['protein'] as int,
      portions: json['portions'] as int,
      ingredients: (json['ingredients'] as List)
          .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String,
      mealType: MealType.fromName(json['mealType'] as String),
      photoPath: photoPath,
      carbs: json['carbs'] as int?,
      fat: json['fat'] as int?,
    );
    final checked = json['checkedIngredients'] as List?;
    if (checked != null && checked.length == recipe.checkedIngredients.length) {
      recipe.checkedIngredients = checked.cast<bool>();
    }
    return recipe;
  }

  /// Builds a [Recipe] from a `community_recipies` Supabase row (snake_case
  /// columns, `ingredients` as jsonb).
  factory Recipe.fromSupabaseRow(Map<String, dynamic> row) => Recipe(
        name: row['name'] as String,
        calories: row['calories'] as int,
        protein: row['protein'] as int,
        portions: row['portions'] as int,
        ingredients: (row['ingredients'] as List)
            .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
            .toList(),
        description: row['description'] as String,
        mealType: MealType.fromName(row['meal_type'] as String),
        photoPath: row['photo_path'] as String?,
        carbs: row['carbs'] as int?,
        fat: row['fat'] as int?,
      );
}
