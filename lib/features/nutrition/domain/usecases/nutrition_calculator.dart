import '../../../../core/units/unit.dart';
import '../entities/food.dart';
import '../repositories/food_repository.dart';
import 'food_matcher.dart';
import 'unit_conversion.dart';

/// Plausibility checks on a [Food]'s per-100g values. Never invents or
/// corrects a value — only flags ones that look wrong (negative, or above
/// a generous ceiling for any whole food/ingredient) so bad source data is
/// visible instead of silently propagating into a recipe's totals.
List<String> validateFoodNutrition(Food food) {
  final issues = <String>[];
  void check(String label, double? value, double max) {
    if (value == null) return;
    if (value < 0) issues.add('$label is negative ($value per 100g)');
    if (value > max) issues.add('$label implausibly high ($value per 100g > $max)');
  }

  check('calories', food.caloriesKcal100g, 950);
  check('protein', food.proteinG100g, 100);
  check('carbs', food.carbsG100g, 100);
  check('fat', food.fatG100g, 100);
  check('fiber', food.fiberG100g, 100);
  return issues;
}

/// Full audit trail for one ingredient's calculation — every field the
/// pipeline used, so a wrong result can always be traced back to exactly
/// which match/conversion/data value produced it. `null` nutrition fields
/// mean "not computed" (missing match, low confidence, unresolved
/// conversion, or missing source data) — they are never silently treated
/// as zero when summing recipe totals (see [computeRecipeTotals]).
class IngredientCalculationDebug {
  const IngredientCalculationDebug({
    required this.ingredientEntered,
    required this.matchedFood,
    required this.matchConfidence,
    required this.matchReason,
    required this.needsConfirmation,
    required this.alternativeCandidates,
    required this.amount,
    required this.unit,
    required this.conversion,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.dataIssues,
  });

  final String ingredientEntered;
  final Food? matchedFood;
  final double? matchConfidence;
  final String? matchReason;
  final bool needsConfirmation;
  final List<FoodMatch> alternativeCandidates;
  final double? amount;
  final Unit unit;
  final GramsConversion? conversion;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final double? fiber;

  /// Anything worth a human's attention: low-confidence match, unresolved
  /// conversion, implausible source nutrition, missing quantity, etc.
  final List<String> dataIssues;

  String toDebugRow() {
    final food = matchedFood;
    return [
      'entered="$ingredientEntered"',
      'matched=${food == null ? '(none)' : '"${food.foodName}"'}',
      'confidence=${matchConfidence?.toStringAsFixed(2) ?? '-'}',
      'needsConfirmation=$needsConfirmation',
      'amount=${amount ?? '-'} ${unit.id}',
      'conversionMethod=${conversion?.method.name ?? '-'}',
      'factor=${conversion?.factorUsed ?? '-'}',
      'grams=${conversion?.grams?.toStringAsFixed(1) ?? '-'}',
      'kcal/100g=${food?.caloriesKcal100g ?? '-'}',
      'protein/100g=${food?.proteinG100g ?? '-'}',
      'calories=${calories?.toStringAsFixed(1) ?? '-'}',
      'protein=${protein?.toStringAsFixed(2) ?? '-'}',
      if (dataIssues.isNotEmpty) 'issues=[${dataIssues.join('; ')}]',
    ].join(' | ');
  }
}

/// Runs one ingredient through the full pipeline: match -> validate ->
/// convert to grams -> scale per-100g values. Stops (with a null nutrition
/// result and a recorded reason) at the first step that isn't confidently
/// resolved, rather than guessing past it.
Future<IngredientCalculationDebug> calculateIngredientNutrition({
  required FoodRepository repository,
  required FoodMatcher matcher,
  required String ingredientName,
  required double? amount,
  required Unit unit,
}) async {
  final matchResult = await matcher.match(ingredientName);
  final best = matchResult.best;

  if (best == null) {
    return IngredientCalculationDebug(
      ingredientEntered: ingredientName,
      matchedFood: null,
      matchConfidence: null,
      matchReason: null,
      needsConfirmation: true,
      alternativeCandidates: matchResult.candidates,
      amount: amount,
      unit: unit,
      conversion: null,
      calories: null,
      protein: null,
      carbs: null,
      fat: null,
      fiber: null,
      dataIssues: const ['no candidate food found'],
    );
  }

  final dataIssues = validateFoodNutrition(best.food);

  if (matchResult.needsConfirmation) {
    return IngredientCalculationDebug(
      ingredientEntered: ingredientName,
      matchedFood: best.food,
      matchConfidence: best.confidence,
      matchReason: best.reason,
      needsConfirmation: true,
      alternativeCandidates: matchResult.candidates,
      amount: amount,
      unit: unit,
      conversion: null,
      calories: null,
      protein: null,
      carbs: null,
      fat: null,
      fiber: null,
      dataIssues: [
        ...dataIssues,
        if (best.confidence < FoodMatcher.autoAcceptThreshold)
          'match confidence ${best.confidence.toStringAsFixed(2)} below '
              'auto-accept threshold ${FoodMatcher.autoAcceptThreshold} — needs confirmation'
        else
          'tied with a close runner-up candidate '
              '("${matchResult.candidates[1].food.foodName}", '
              'confidence ${matchResult.candidates[1].confidence.toStringAsFixed(2)}) — '
              'needs confirmation rather than an arbitrary pick',
      ],
    );
  }

  if (amount == null) {
    return IngredientCalculationDebug(
      ingredientEntered: ingredientName,
      matchedFood: best.food,
      matchConfidence: best.confidence,
      matchReason: best.reason,
      needsConfirmation: false,
      alternativeCandidates: matchResult.candidates,
      amount: null,
      unit: unit,
      conversion: null,
      calories: null,
      protein: null,
      carbs: null,
      fat: null,
      fiber: null,
      dataIssues: [...dataIssues, 'no quantity provided'],
    );
  }

  final nutrition = await calculateKnownIngredientNutrition(
    repository: repository,
    food: best.food,
    amount: amount,
    unit: unit,
  );

  return IngredientCalculationDebug(
    ingredientEntered: ingredientName,
    matchedFood: best.food,
    matchConfidence: best.confidence,
    matchReason: best.reason,
    needsConfirmation: false,
    alternativeCandidates: matchResult.candidates,
    amount: amount,
    unit: unit,
    conversion: nutrition.conversion,
    calories: nutrition.calories,
    protein: nutrition.protein,
    carbs: nutrition.carbs,
    fat: nutrition.fat,
    fiber: nutrition.fiber,
    dataIssues: nutrition.conversion.isFlagged
        ? [...dataIssues, nutrition.conversion.note]
        : dataIssues,
  );
}

/// Calories/protein/carbs/fat/fiber for an already-identified [food] at the
/// given amount+unit — for when the food was picked explicitly (e.g. a user
/// tapped a suggestion), so re-running [FoodMatcher] would be redundant.
/// Still goes through the same conversion (DB-exact -> reference -> flagged)
/// as the full pipeline, and still returns null fields rather than
/// guessing when grams can't be resolved or source data is missing.
typedef IngredientNutrition = ({
  GramsConversion conversion,
  double? calories,
  double? protein,
  double? carbs,
  double? fat,
  double? fiber,
});

Future<IngredientNutrition> calculateKnownIngredientNutrition({
  required FoodRepository repository,
  required Food food,
  required double amount,
  required Unit unit,
}) async {
  final conversion = await convertIngredientToGrams(
    repository: repository,
    food: food,
    amount: amount,
    unit: unit,
  );
  if (conversion.grams == null) {
    return (
      conversion: conversion,
      calories: null,
      protein: null,
      carbs: null,
      fat: null,
      fiber: null,
    );
  }
  final factor = conversion.grams! / 100;
  double? scale(double? per100g) => per100g == null ? null : factor * per100g;
  return (
    conversion: conversion,
    calories: scale(food.caloriesKcal100g),
    protein: scale(food.proteinG100g),
    carbs: scale(food.carbsG100g),
    fat: scale(food.fatG100g),
    fiber: scale(food.fiberG100g),
  );
}

/// A recipe's nutrition, always computed as total-first-then-divided —
/// never the reverse. [servings] must be an explicit, known count (never
/// silently assumed) since dividing by an assumed serving count would
/// silently fabricate a number.
class RecipeNutritionTotals {
  const RecipeNutritionTotals({
    required this.totalCalories,
    required this.totalProtein,
    required this.servings,
    required this.incompleteIngredients,
  });

  final double totalCalories;
  final double totalProtein;
  final int servings;

  /// Names of ingredients that did NOT contribute to the total (no match,
  /// needs confirmation, or unresolved conversion) — the total is a
  /// deliberate undercount when this is non-empty, not a silent 0.
  final List<String> incompleteIngredients;

  double get perServingCalories => totalCalories / servings;
  double get perServingProtein => totalProtein / servings;
}

RecipeNutritionTotals computeRecipeTotals(
  List<IngredientCalculationDebug> perIngredient, {
  required int servings,
}) {
  assert(servings > 0, 'servings must be an explicit positive count, not assumed');

  var totalCalories = 0.0;
  var totalProtein = 0.0;
  final incomplete = <String>[];

  for (final ingredient in perIngredient) {
    if (ingredient.calories != null) {
      totalCalories += ingredient.calories!;
    } else {
      incomplete.add(ingredient.ingredientEntered);
    }
    if (ingredient.protein != null) totalProtein += ingredient.protein!;
  }

  return RecipeNutritionTotals(
    totalCalories: totalCalories,
    totalProtein: totalProtein,
    servings: servings,
    incompleteIngredients: incomplete,
  );
}
