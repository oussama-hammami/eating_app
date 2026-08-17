import 'package:eating_app/core/units/unit.dart';
import 'package:eating_app/features/nutrition/data/datasources/food_local_data_source.dart';
import 'package:eating_app/features/nutrition/data/repositories/food_repository_impl.dart';
import 'package:eating_app/features/nutrition/domain/entities/food.dart';
import 'package:eating_app/features/nutrition/domain/usecases/food_matcher.dart';
import 'package:eating_app/features/nutrition/domain/usecases/nutrition_calculator.dart';
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

  group('full pipeline: match -> validate -> convert -> scale', () {
    test('confident match + known grams -> computed nutrition', () async {
      final result = await calculateIngredientNutrition(
        repository: repository,
        matcher: matcher,
        ingredientName: 'oat raw',
        amount: 40,
        unit: Unit.g,
      );

      expect(result.needsConfirmation, isFalse);
      expect(result.matchedFood!.foodName, 'Oat, raw');
      expect(result.calories, closeTo(40 / 100 * 378.0, 0.001));
      expect(result.protein, closeTo(40 / 100 * 16.9, 0.001));
    });

    test('low-confidence match ("Greek yogurt") does not compute nutrition silently', () async {
      final result = await calculateIngredientNutrition(
        repository: repository,
        matcher: matcher,
        ingredientName: 'Greek yogurt',
        amount: 120,
        unit: Unit.g,
      );

      expect(result.needsConfirmation, isTrue);
      expect(result.calories, isNull);
      expect(result.protein, isNull);
      expect(result.dataIssues, anyElement(contains('needs confirmation')));
    });

    test('null nutrition values: a confidently-matched food with no calorie data propagates null, not 0', () async {
      final result = await calculateIngredientNutrition(
        repository: repository,
        matcher: matcher,
        ingredientName: 'vanilla pod',
        amount: 1,
        unit: Unit.piece,
      );

      expect(result.needsConfirmation, isFalse); // exact match on its own name
      expect(result.matchedFood!.foodName, 'Vanilla, pod');
      // Conversion is flagged (no piece weight for a vanilla pod), so
      // nutrition is null for a different reason too — but crucially it's
      // never silently 0.
      expect(result.calories, isNull);
    });

    test('unresolved conversion leaves nutrition null with a recorded reason', () async {
      final result = await calculateIngredientNutrition(
        repository: repository,
        matcher: matcher,
        ingredientName: 'almond peeled no added salt',
        amount: 1,
        unit: Unit.tsp,
      );

      expect(result.needsConfirmation, isFalse);
      expect(result.calories, isNull);
      expect(result.conversion!.isFlagged, isTrue);
      expect(result.dataIssues, isNotEmpty);
    });

    test('missing quantity leaves nutrition null instead of assuming an amount', () async {
      final result = await calculateIngredientNutrition(
        repository: repository,
        matcher: matcher,
        ingredientName: 'honey',
        amount: null,
        unit: Unit.tsp,
      );

      expect(result.calories, isNull);
      expect(result.dataIssues, contains('no quantity provided'));
    });

    test('no match at all leaves nutrition null', () async {
      final result = await calculateIngredientNutrition(
        repository: repository,
        matcher: matcher,
        ingredientName: 'nonexistent xyzzy food',
        amount: 10,
        unit: Unit.g,
      );

      expect(result.matchedFood, isNull);
      expect(result.calories, isNull);
      expect(result.needsConfirmation, isTrue);
    });
  });

  group('data validation', () {
    test('flags negative and implausibly high per-100g values without altering them', () {
      const negative = Food(
        id: 1,
        foodName: 'bad',
        caloriesKcal100g: -10,
        proteinG100g: 1,
        carbsG100g: 1,
        fatG100g: 1,
        fiberG100g: 1,
      );
      final issues = validateFoodNutrition(negative);
      expect(issues, isNotEmpty);
      expect(issues.first, contains('negative'));
      // The raw value is untouched — validation only reports, never fixes.
      expect(negative.caloriesKcal100g, -10);
    });

    test('flags implausibly high values', () {
      const huge = Food(
        id: 2,
        foodName: 'bad',
        caloriesKcal100g: 5000,
        proteinG100g: 1,
        carbsG100g: 1,
        fatG100g: 1,
        fiberG100g: 1,
      );
      expect(validateFoodNutrition(huge), isNotEmpty);
    });

    test('null values are not flagged as invalid (they mean "unknown", handled elsewhere)', () {
      const missing = Food(
        id: 3,
        foodName: 'unknown data',
        caloriesKcal100g: null,
        proteinG100g: null,
        carbsG100g: null,
        fatG100g: null,
        fiberG100g: null,
      );
      expect(validateFoodNutrition(missing), isEmpty);
    });

    test('plausible values raise no issues', () {
      const fine = Food(
        id: 4,
        foodName: 'fine',
        caloriesKcal100g: 150,
        proteinG100g: 10,
        carbsG100g: 20,
        fatG100g: 5,
        fiberG100g: 2,
      );
      expect(validateFoodNutrition(fine), isEmpty);
    });
  });

  group('recipe totals: total first, then divide by an explicit serving count', () {
    test('sums only the ingredients that resolved, tracks the rest as incomplete', () async {
      final oats = await calculateIngredientNutrition(
        repository: repository,
        matcher: matcher,
        ingredientName: 'oat raw',
        amount: 40,
        unit: Unit.g,
      );
      final blueberries = await calculateIngredientNutrition(
        repository: repository,
        matcher: matcher,
        ingredientName: 'blueberry raw',
        amount: 50,
        unit: Unit.g,
      );
      final unresolved = await calculateIngredientNutrition(
        repository: repository,
        matcher: matcher,
        ingredientName: 'Greek yogurt',
        amount: 120,
        unit: Unit.g,
      );

      final totals = computeRecipeTotals([oats, blueberries, unresolved], servings: 2);

      final expectedCalories = (40 / 100 * 378.0) + (50 / 100 * 57.7);
      expect(totals.totalCalories, closeTo(expectedCalories, 0.001));
      expect(totals.incompleteIngredients, ['Greek yogurt']);

      // Per-serving must be total / servings, computed AFTER the total.
      expect(totals.perServingCalories, closeTo(expectedCalories / 2, 0.001));
    });

    test('per-serving requires an explicit positive serving count', () async {
      final oats = await calculateIngredientNutrition(
        repository: repository,
        matcher: matcher,
        ingredientName: 'oat raw',
        amount: 40,
        unit: Unit.g,
      );

      expect(
        () => computeRecipeTotals([oats], servings: 0),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
