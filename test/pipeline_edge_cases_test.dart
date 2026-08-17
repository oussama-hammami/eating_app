// Fills gaps in the existing food_matcher_test.dart / nutrition_calculator_test.dart
// / unit_conversion_test.dart suites: additional "must not silently match"
// food pairs, invalid-quantity handling (documents current behavior — see
// KNOWN ISSUES comments below for cases that are NOT rejected today), and
// cross-cutting invariants (precision, monotonicity, servings independence).
import 'package:eating_app/core/units/unit.dart';
import 'package:eating_app/features/nutrition/data/datasources/food_local_data_source.dart';
import 'package:eating_app/features/nutrition/data/repositories/food_repository_impl.dart';
import 'package:eating_app/features/nutrition/domain/usecases/food_matcher.dart';
import 'package:eating_app/features/nutrition/domain/usecases/nutrition_calculator.dart';
import 'package:eating_app/features/nutrition/domain/usecases/unit_conversion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'fixtures/food_db_fixture.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late FoodRepositoryImpl repository;
  late FoodMatcher matcher;

  setUp(() async {
    db = await seedFoodDbFixture();
    repository = FoodRepositoryImpl(FoodLocalDataSource(db));
    matcher = FoodMatcher(repository);
  });

  tearDown(() async => db.close());

  group('A/H. food matching: must-not-silently-match pairs', () {
    test('should_not_match_coconut_milk_to_plain_coconut', () async {
      final result = await matcher.match('coconut milk');
      expect(result.best!.food.foodName, isNot('Coconut, pulp, fresh'));
      expect(result.best!.food.foodName, 'Coconut milk');
      expect(result.needsConfirmation, isFalse);
    });

    // KNOWN ISSUE (documented, not fixed — see final report "Food matching
    // problems"): a bare, single-word query auto-accepts a candidate that
    // covers it plus exactly one trailing qualifier (the scorer's "free
    // trailing allowance", by design for cases like "yogurt" -> "Yogurt
    // (average)"). That same rule lets "coconut" alone auto-resolve to
    // "Coconut milk" (1.0 confidence) instead of "Coconut, pulp, fresh" or
    // flagging ambiguity between the two very different products.
    test('BUG: bare "coconut" auto-accepts "Coconut milk" at full confidence, not flagged', () async {
      final result = await matcher.match('coconut');
      final milk = result.candidates.where((c) => c.food.foodName == 'Coconut milk');
      expect(milk, isNotEmpty);
      expect(milk.first.confidence, 1.0);
      expect(result.needsConfirmation, isFalse);
      expect(result.best!.food.foodName, 'Coconut milk');
    });

    test('should_not_blindly_match_egg_to_egg_white_or_egg_yolk', () async {
      final result = await matcher.match('egg');
      expect(result.best!.food.foodName, 'Egg, raw');
      expect(result.needsConfirmation, isFalse);
    });

    test('should_require_confirmation_or_reject_ambiguous_egg_family_query', () async {
      // "egg white" should resolve to the white specifically, not fall back
      // to plain "Egg, raw" nor blindly grab the yolk.
      final result = await matcher.match('egg white');
      expect(result.best!.food.foodName, 'Egg white, raw');
    });

    test('should_not_blindly_match_whole_wheat_bread_to_white_bread', () async {
      final result = await matcher.match('whole wheat bread');
      expect(result.best!.food.foodName, isNot('Bread, white'));
      expect(result.best!.food.foodName, 'Bread, whole wheat');
    });
  });

  group('G/I. invalid inputs: unknown / empty / ambiguous', () {
    test('should_reject_empty_ingredient_name', () async {
      final result = await matcher.match('');
      expect(result.best, isNull);
      expect(result.candidates, isEmpty);
    });

    test('should_reject_whitespace_only_ingredient_name', () async {
      final result = await matcher.match('   ');
      expect(result.best, isNull);
    });

    test('should_require_confirmation_for_low_confidence_match_not_auto_accept', () async {
      final result = await matcher.match('almond milk');
      expect(result.needsConfirmation, isTrue);
    });
  });

  group('J/K. quantity edge cases — documents ACTUAL current behavior', () {
    test('should_calculate_zero_kcal_for_0_grams', () async {
      final result = await calculateIngredientNutrition(
        repository: repository,
        matcher: matcher,
        ingredientName: 'oat raw',
        amount: 0,
        unit: Unit.g,
      );
      expect(result.calories, 0.0);
      expect(result.protein, 0.0);
    });

    // KNOWN ISSUE (documented, not fixed — see final report "Invalid
    // nutrition / quantity problems"): the pipeline has no guard against a
    // negative amount anywhere in calculateIngredientNutrition,
    // convertIngredientToGrams, or calculateKnownIngredientNutrition. A
    // negative quantity silently produces negative "nutrition" instead of
    // being rejected. This test intentionally asserts the CURRENT (buggy)
    // behavior so a future fix is a visible, deliberate test change rather
    // than a silent regression discovery.
    test('BUG: negative amount is NOT rejected — silently produces negative calories', () async {
      final result = await calculateIngredientNutrition(
        repository: repository,
        matcher: matcher,
        ingredientName: 'oat raw',
        amount: -40,
        unit: Unit.g,
      );
      expect(result.calories, isNotNull);
      expect(result.calories, lessThan(0));
      expect(result.dataIssues, isNot(contains(matches(RegExp('negative amount', caseSensitive: false)))));
    });

    // KNOWN ISSUE: same absence of a guard for negative piece counts.
    test('BUG: negative piece count is NOT rejected — produces negative grams', () async {
      final result = await convertIngredientToGrams(
        repository: repository,
        food: (await matcher.match('egg')).best!.food,
        amount: -1,
        unit: Unit.piece,
      );
      expect(result.grams, -50.0);
    });

    test('should_scale_calories_exactly_at_100g_to_the_per_100g_database_value', () async {
      final result = await calculateIngredientNutrition(
        repository: repository,
        matcher: matcher,
        ingredientName: 'oat raw',
        amount: 100,
        unit: Unit.g,
      );
      expect(result.calories, 378.0);
      expect(result.protein, 16.9);
    });

    test('should_double_calories_when_doubling_grams_from_100_to_200', () async {
      final at100 = await calculateIngredientNutrition(
        repository: repository,
        matcher: matcher,
        ingredientName: 'oat raw',
        amount: 100,
        unit: Unit.g,
      );
      final at200 = await calculateIngredientNutrition(
        repository: repository,
        matcher: matcher,
        ingredientName: 'oat raw',
        amount: 200,
        unit: Unit.g,
      );
      expect(at200.calories, closeTo(at100.calories! * 2, 1e-9));
    });
  });

  group('E/K. recipe totals: precision — do not round before summing', () {
    test('should_not_round_individual_ingredients_before_total', () async {
      // 33g and 34g of oats (378 kcal/100g) individually round to a total
      // that differs from summing the exact intermediate values first —
      // 33g -> 124.74 (rounds to 125), 34g -> 128.52 (rounds to 129),
      // sum-of-rounded = 254, but the exact sum is 253.26.
      final a = await calculateIngredientNutrition(
        repository: repository,
        matcher: matcher,
        ingredientName: 'oat raw',
        amount: 33,
        unit: Unit.g,
      );
      final b = await calculateIngredientNutrition(
        repository: repository,
        matcher: matcher,
        ingredientName: 'oat raw',
        amount: 34,
        unit: Unit.g,
      );

      final totals = computeRecipeTotals([a, b], servings: 1);

      final exactSum = (33 / 100 * 378.0) + (34 / 100 * 378.0);
      final sumOfRounded = a.calories!.round() + b.calories!.round();

      expect(totals.totalCalories, closeTo(exactSum, 1e-9));
      // The two quantities are deliberately picked so rounding each first
      // changes the result — proving the implementation keeps full
      // precision internally rather than rounding per-ingredient.
      expect(totals.totalCalories, isNot(closeTo(sumOfRounded.toDouble(), 1e-9)));
    });
  });

  group('F. servings invariants', () {
    test('should_keep_recipe_total_unchanged_by_serving_count', () async {
      final oats = await calculateIngredientNutrition(
        repository: repository,
        matcher: matcher,
        ingredientName: 'oat raw',
        amount: 40,
        unit: Unit.g,
      );
      final totalsFor2 = computeRecipeTotals([oats], servings: 2);
      final totalsFor4 = computeRecipeTotals([oats], servings: 4);
      expect(totalsFor2.totalCalories, totalsFor4.totalCalories);
    });

    test('should_halve_per_serving_calories_when_doubling_servings', () async {
      final oats = await calculateIngredientNutrition(
        repository: repository,
        matcher: matcher,
        ingredientName: 'oat raw',
        amount: 100,
        unit: Unit.g,
      );
      final totalsFor2 = computeRecipeTotals([oats], servings: 2);
      final totalsFor4 = computeRecipeTotals([oats], servings: 4);
      expect(totalsFor4.perServingCalories, closeTo(totalsFor2.perServingCalories / 2, 1e-9));
    });

    test('should_reject_negative_serving_count_via_assertion', () async {
      expect(
        () => computeRecipeTotals(const [], servings: -1),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('D. increasing amount never decreases calories for a positive-nutrition food', () {
    test('should_never_decrease_calories_as_grams_increase', () async {
      final amounts = [0.0, 10.0, 40.0, 100.0, 250.0];
      double? previous;
      for (final amount in amounts) {
        final result = await calculateIngredientNutrition(
          repository: repository,
          matcher: matcher,
          ingredientName: 'oat raw',
          amount: amount,
          unit: Unit.g,
        );
        if (previous != null) {
          expect(result.calories!, greaterThanOrEqualTo(previous));
        }
        previous = result.calories;
      }
    });
  });
}
