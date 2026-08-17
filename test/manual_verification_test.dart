// Ad-hoc verification against the REAL on-device CIQUAL database (not a
// synthetic fixture) for the exact recipe given in the audit request:
// High-Protein Greek Yogurt Pancakes — 40g rolled oats, 120g plain Greek
// yogurt, 2 large eggs (~100g edible), 2.5g vanilla extract, 1.3g cinnamon,
// 50g blueberries, 7g honey. Run with:
//   flutter test test/manual_verification_test.dart
import 'package:eating_app/core/units/unit.dart';
import 'package:eating_app/features/nutrition/data/datasources/food_local_data_source.dart';
import 'package:eating_app/features/nutrition/data/repositories/food_repository_impl.dart';
import 'package:eating_app/features/nutrition/domain/usecases/food_matcher.dart';
import 'package:eating_app/features/nutrition/domain/usecases/nutrition_calculator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('audit the exact test recipe against the real on-device database', () async {
    final path = File('assets/db/nutrition.db').absolute.path;
    final db = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(readOnly: true),
    );
    final repository = FoodRepositoryImpl(FoodLocalDataSource(db));
    final matcher = FoodMatcher(repository);

    final ingredients = [
      ('rolled oats', 40.0, Unit.g),
      ('plain Greek yogurt', 120.0, Unit.g),
      ('eggs', 100.0, Unit.g), // 2 large eggs, ~100g edible weight
      ('vanilla extract', 2.5, Unit.g),
      ('cinnamon', 1.3, Unit.g),
      ('blueberries', 50.0, Unit.g),
      ('honey', 7.0, Unit.g),
    ];

    final rows = <IngredientCalculationDebug>[];
    for (final (name, amount, unit) in ingredients) {
      rows.add(
        await calculateIngredientNutrition(
          repository: repository,
          matcher: matcher,
          ingredientName: name,
          amount: amount,
          unit: unit,
        ),
      );
    }

    // ignore: avoid_print
    print('--- High-Protein Greek Yogurt Pancakes: audit against real DB ---');
    for (final row in rows) {
      // ignore: avoid_print
      print(row.toDebugRow());
    }

    final totals = computeRecipeTotals(rows, servings: 1);
    // ignore: avoid_print
    print(
      'TOTAL: ${totals.totalCalories.toStringAsFixed(1)} kcal, '
      '${totals.totalProtein.toStringAsFixed(1)} g protein '
      '(incomplete: ${totals.incompleteIngredients})',
    );

    await db.close();

    // The two examples explicitly called out as bad matches must not recur.
    final greekYogurt = rows[1];
    expect(greekYogurt.matchedFood?.foodName, isNot("Yogurt, Greek-style, ewe's milk"));

    final vanilla = rows[3];
    expect(vanilla.matchedFood?.foodName, isNot('Vanilla, pod'));
  });
}
