import 'ingredient.dart';
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
    this.fiber = const NutrientRange(),
    this.includeIngredients = const {},
    this.excludeIngredients = const {},
    this.mealTypes = const {},
  });

  final NutrientRange calories;
  final NutrientRange protein;
  final NutrientRange carbs;
  final NutrientRange fat;
  final NutrientRange fiber;

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
      fiber.isActive ||
      includeIngredients.isNotEmpty ||
      excludeIngredients.isNotEmpty ||
      mealTypes.isNotEmpty;

  RecipeFilter copyWith({
    NutrientRange? calories,
    NutrientRange? protein,
    NutrientRange? carbs,
    NutrientRange? fat,
    NutrientRange? fiber,
    Set<String>? includeIngredients,
    Set<String>? excludeIngredients,
    Set<MealType>? mealTypes,
  }) {
    return RecipeFilter(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      includeIngredients: includeIngredients ?? this.includeIngredients,
      excludeIngredients: excludeIngredients ?? this.excludeIngredients,
      mealTypes: mealTypes ?? this.mealTypes,
    );
  }
}

/// Sums a per-ingredient nutrient across [recipe.ingredients], treating a
/// missing (unmatched/unconfirmed) value as 0 — the same convention used by
/// [computeRecipeTotals] for calories/protein.
double _sumIngredientNutrient(Recipe recipe, double? Function(Ingredient ingredient) select) {
  var total = 0.0;
  for (final ingredient in recipe.ingredients) {
    total += select(ingredient) ?? 0;
  }
  return total;
}

/// Prefers the recipe's own curated total ([Recipe.carbs]/[Recipe.fat])
/// when known; otherwise falls back to summing per-ingredient values.
double recipeCarbsTotal(Recipe recipe) =>
    recipe.carbs?.toDouble() ?? _sumIngredientNutrient(recipe, (i) => i.carbs);
double recipeFatTotal(Recipe recipe) =>
    recipe.fat?.toDouble() ?? _sumIngredientNutrient(recipe, (i) => i.fat);

/// No recipe-level total exists for fiber (not provided by curated
/// datasets), so this always sums per-ingredient values.
double recipeFiberTotal(Recipe recipe) => _sumIngredientNutrient(recipe, (i) => i.fiber);

/// Whether [recipe] satisfies every active criterion in [filter].
bool recipeMatchesFilter(Recipe recipe, RecipeFilter filter) {
  if (!filter.calories.matches(recipe.calories.toDouble())) return false;
  if (!filter.protein.matches(recipe.protein.toDouble())) return false;
  if (filter.carbs.isActive && !filter.carbs.matches(recipeCarbsTotal(recipe))) return false;
  if (filter.fat.isActive && !filter.fat.matches(recipeFatTotal(recipe))) return false;
  if (filter.fiber.isActive && !filter.fiber.matches(recipeFiberTotal(recipe))) return false;

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
