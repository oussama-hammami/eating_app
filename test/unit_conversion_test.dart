import 'package:eating_app/core/units/unit.dart';
import 'package:eating_app/features/nutrition/data/datasources/food_local_data_source.dart';
import 'package:eating_app/features/nutrition/data/repositories/food_repository_impl.dart';
import 'package:eating_app/features/nutrition/domain/entities/food.dart';
import 'package:eating_app/features/nutrition/domain/usecases/unit_conversion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'fixtures/food_db_fixture.dart';

const _dummyNutrition = (calories: 100.0, protein: 1.0);

Food _food(int id, String name) => Food(
  id: id,
  foodName: name,
  caloriesKcal100g: _dummyNutrition.calories,
  proteinG100g: _dummyNutrition.protein,
  carbsG100g: 1,
  fatG100g: 1,
  fiberG100g: 1,
);

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late FoodRepositoryImpl repository;

  setUp(() async {
    db = await seedFoodDbFixture();
    repository = FoodRepositoryImpl(FoodLocalDataSource(db));
  });

  tearDown(() async => db.close());

  group('grams-based units (exact, universal)', () {
    test('grams: 40 g -> 40 g', () async {
      final result = await convertIngredientToGrams(
        repository: repository,
        food: _food(9, 'Oat, raw'),
        amount: 40,
        unit: Unit.g,
      );
      expect(result.grams, 40);
      expect(result.method, ConversionMethod.weightExact);
    });

    test('kg: 1 kg -> 1000 g', () async {
      final result = await convertIngredientToGrams(
        repository: repository,
        food: _food(9, 'Oat, raw'),
        amount: 1,
        unit: Unit.kg,
      );
      expect(result.grams, 1000);
      expect(result.method, ConversionMethod.weightExact);
    });

    test('oz: 1 oz -> 28.3495 g', () async {
      final result = await convertIngredientToGrams(
        repository: repository,
        food: _food(9, 'Oat, raw'),
        amount: 1,
        unit: Unit.oz,
      );
      expect(result.grams, closeTo(28.3495, 0.0001));
    });

    test('lb: 1 lb -> 453.592 g', () async {
      final result = await convertIngredientToGrams(
        repository: repository,
        food: _food(9, 'Oat, raw'),
        amount: 1,
        unit: Unit.lb,
      );
      expect(result.grams, closeTo(453.592, 0.001));
    });
  });

  group('volume units: exact ml, need a density for anything else', () {
    test('ml: 250 ml is exact regardless of density (still needs one to become grams)', () async {
      // ml itself has a universal factor to... ml; grams still require a
      // density, so with no reference/db density this is flagged.
      final result = await convertIngredientToGrams(
        repository: repository,
        food: _food(5, 'Almond, peeled, no added salt'),
        amount: 250,
        unit: Unit.ml,
      );
      expect(result.grams, isNull);
      expect(result.method, ConversionMethod.unresolvedFlagged);
    });

    test('tsp/tbsp/cup all convert to ml correctly once a density is known (honey)', () async {
      final tsp = await convertIngredientToGrams(
        repository: repository,
        food: _food(8, 'Honey'),
        amount: 1,
        unit: Unit.tsp,
      );
      // 1 tsp = 4.92892 ml; honey reference density = 1.42 g/ml.
      expect(tsp.grams, closeTo(4.92892 * 1.42, 0.001));
      expect(tsp.method, ConversionMethod.referenceApprox);

      final tbsp = await convertIngredientToGrams(
        repository: repository,
        food: _food(8, 'Honey'),
        amount: 1,
        unit: Unit.tbsp,
      );
      expect(tbsp.grams, closeTo(14.7868 * 1.42, 0.001));

      final cup = await convertIngredientToGrams(
        repository: repository,
        food: _food(8, 'Honey'),
        amount: 1,
        unit: Unit.cup,
      );
      expect(cup.grams, closeTo(236.588 * 1.42, 0.01));
    });

    test('ingredient-specific density: cinnamon powder uses cinnamon density, not water', () async {
      final result = await convertIngredientToGrams(
        repository: repository,
        food: _food(7, 'Cinnamon, powder'),
        amount: 0.5,
        unit: Unit.tsp,
      );
      // 0.5 tsp = 2.46446 ml; cinnamon reference density = 0.56 g/ml.
      expect(result.grams, closeTo(2.46446 * 0.56, 0.001));
      expect(result.grams, isNot(closeTo(2.46446 * 1.0, 0.001))); // must not be water density
      expect(result.method, ConversionMethod.referenceApprox);
    });
  });

  group('piece-based units', () {
    test('database-exact: egg has a food_unit_conversions factor (50 g/piece)', () async {
      final result = await convertIngredientToGrams(
        repository: repository,
        food: _food(4, 'Egg, raw'),
        amount: 2,
        unit: Unit.piece,
      );
      expect(result.grams, 100);
      expect(result.method, ConversionMethod.databaseExact);
      expect(result.factorUsed, 50);
    });

    test('ingredient-specific piece weight: banana falls back to the reference table', () async {
      final result = await convertIngredientToGrams(
        repository: repository,
        food: _food(99, 'Banana, flesh without skin, raw'),
        amount: 1,
        unit: Unit.piece,
      );
      expect(result.grams, 118);
      expect(result.method, ConversionMethod.referenceApprox);
    });

    test('unknown piece weight is flagged, not guessed', () async {
      final result = await convertIngredientToGrams(
        repository: repository,
        food: _food(5, 'Almond, peeled, no added salt'),
        amount: 3,
        unit: Unit.piece,
      );
      expect(result.grams, isNull);
      expect(result.method, ConversionMethod.unresolvedFlagged);
      expect(result.note, contains('flagged'));
    });
  });

  group('never silently assumes water density (1.0) for an unknown ingredient', () {
    test('a food with no db conversion and no reference entry is flagged for tsp', () async {
      final result = await convertIngredientToGrams(
        repository: repository,
        food: _food(5, 'Almond, peeled, no added salt'),
        amount: 1,
        unit: Unit.tsp,
      );
      expect(result.grams, isNull);
      expect(result.method, ConversionMethod.unresolvedFlagged);
    });
  });
}
