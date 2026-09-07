import 'meal_type.dart';
import 'recipe.dart';

/// An inclusive min/max bound on a nutrient value. Either side may be null
/// to leave that bound unconstrained.
class NutrientRange {
  const NutrientRange({this.min, this.max});

  final double? min;
  final double? max;

  bool get isActive => min != null || max != null;

  NutrientRange copyWith({double? min, bool clearMin = false, double? max, bool clearMax = false}) {
    return NutrientRange(
      min: clearMin ? null : (min ?? this.min),
      max: clearMax ? null : (max ?? this.max),
    );
  }

  bool matches(double value) {
    if (min != null && value < min!) return false;
    if (max != null && value > max!) return false;
    return true;
  }
}

/// Filter criteria applied to a recipe list: nutrient ranges, ingredients
/// that must/must-not appear, and an allowed subset of meal types.
class RecipeFilter {
  const RecipeFilter({
    this.calories = const NutrientRange(),
    this.protein = const NutrientRange(),
    this.carbs = const NutrientRange(),
    this.fat = const NutrientRange(),
    this.includeIngredients = const {},
    this.excludeIngredients = const {},
    this.mealTypes = const {},
  });

  final NutrientRange calories;
  final NutrientRange protein;
  final NutrientRange carbs;
  final NutrientRange fat;

  /// Ingredient name substrings (lowercase) a recipe must contain at least
  /// one ingredient matching, for each entry.
  final Set<String> includeIngredients;

  /// Ingredient name substrings (lowercase) a recipe must NOT contain any
  /// ingredient matching.
  final Set<String> excludeIngredients;

  /// Meal types a recipe's [Recipe.mealType] must be one of. Empty means
  /// every meal type is allowed.
  final Set<MealType> mealTypes;

  bool get isActive =>
      calories.isActive ||
      protein.isActive ||
      carbs.isActive ||
      fat.isActive ||
      includeIngredients.isNotEmpty ||
      excludeIngredients.isNotEmpty ||
      mealTypes.isNotEmpty;

  RecipeFilter copyWith({
    NutrientRange? calories,
    NutrientRange? protein,
    NutrientRange? carbs,
    NutrientRange? fat,
    Set<String>? includeIngredients,
    Set<String>? excludeIngredients,
    Set<MealType>? mealTypes,
  }) {
    return RecipeFilter(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      includeIngredients: includeIngredients ?? this.includeIngredients,
      excludeIngredients: excludeIngredients ?? this.excludeIngredients,
      mealTypes: mealTypes ?? this.mealTypes,
    );
  }
}

/// Whether [recipe] satisfies every active criterion in [filter]. Nutrient
/// ranges are matched against the recipe's own curated totals (there is no
/// more per-ingredient nutrition to sum).
bool recipeMatchesFilter(Recipe recipe, RecipeFilter filter) {
  if (!filter.calories.matches(recipe.calories.toDouble())) return false;
  if (!filter.protein.matches(recipe.protein.toDouble())) return false;
  // A null carbs/fat means the recipe's nutrition for that field is simply
  // unknown, not zero — filtering it against an active range would wrongly
  // exclude it, so only apply the range when a value is actually present.
  if (filter.carbs.isActive && recipe.carbs != null && !filter.carbs.matches(recipe.carbs!.toDouble())) {
    return false;
  }
  if (filter.fat.isActive && recipe.fat != null && !filter.fat.matches(recipe.fat!.toDouble())) {
    return false;
  }

  if (filter.mealTypes.isNotEmpty && !filter.mealTypes.contains(recipe.mealType)) return false;

  if (filter.includeIngredients.isNotEmpty) {
    final names = recipe.ingredients.map((i) => i.name.toLowerCase()).toList();
    final hasAllIncludes = filter.includeIngredients.every(
      (needle) => names.any((name) => name.contains(needle)),
    );
    if (!hasAllIncludes) return false;
  }

  if (filter.excludeIngredients.isNotEmpty) {
    final names = recipe.ingredients.map((i) => i.name.toLowerCase()).toList();
    final hasAnyExcluded = filter.excludeIngredients.any(
      (needle) => names.any((name) => name.contains(needle)),
    );
    if (hasAnyExcluded) return false;
  }

  return true;
}
