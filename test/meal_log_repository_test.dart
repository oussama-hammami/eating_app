import 'package:eating_app/core/units/unit.dart';
import 'package:eating_app/features/meal_log/data/datasources/meal_log_local_data_source.dart';
import 'package:eating_app/features/meal_log/data/repositories/meal_log_repository_impl.dart';
import 'package:eating_app/features/meal_log/domain/usecases/macro_calculator.dart';
import 'package:eating_app/features/nutrition/domain/entities/food.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _food = Food(
  id: 1,
  foodName: 'Chicken breast',
  caloriesKcal100g: 165,
  proteinG100g: 31,
  carbsG100g: 0,
  fatG100g: 3.6,
  fiberG100g: 0,
);

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('add, update and delete recalculate macros correctly', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('''
      CREATE TABLE meal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        food_id INTEGER NOT NULL,
        food_name TEXT NOT NULL,
        grams REAL NOT NULL,
        unit TEXT NOT NULL DEFAULT 'g',
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fat REAL NOT NULL,
        logged_at TEXT NOT NULL,
        log_date TEXT NOT NULL
      )
    ''');

    final repository = MealLogRepositoryImpl(MealLogLocalDataSource(db));

    final addMacros = MacroCalculator.fromGrams(_food, 200);
    final entry = await repository.addEntry(
      foodId: _food.id,
      foodName: _food.foodName,
      amount: 200,
      unit: Unit.g,
      calories: addMacros.calories,
      protein: addMacros.protein,
      carbs: addMacros.carbs,
      fat: addMacros.fat,
      logDate: '2026-01-01',
      loggedAt: DateTime(2026, 1, 1),
    );
    expect(entry.calories, 330); // 165 * 200/100
    expect(entry.protein, 62); // 31 * 200/100

    final entries = await repository.getEntriesForDate('2026-01-01');
    expect(entries.length, 1);

    final updateMacros = MacroCalculator.fromGrams(_food, 50);
    final updated = await repository.updateEntry(
      entryId: entry.id,
      amount: 50,
      unit: Unit.g,
      calories: updateMacros.calories,
      protein: updateMacros.protein,
      carbs: updateMacros.carbs,
      fat: updateMacros.fat,
    );
    expect(updated.amount, 50);
    expect(updated.calories, closeTo(82.5, 0.001)); // 165 * 50/100

    await repository.deleteEntry(entry.id);
    final afterDelete = await repository.getEntriesForDate('2026-01-01');
    expect(afterDelete, isEmpty);

    await db.close();
  });

  test('pre-existing rows with no unit column default to grams', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    // Mirrors the OLD schema (pre-unit column) to prove migrated data keeps
    // its original meaning: an old "grams" quantity is unambiguously grams.
    await db.execute('''
      CREATE TABLE meal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        food_id INTEGER NOT NULL,
        food_name TEXT NOT NULL,
        grams REAL NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fat REAL NOT NULL,
        logged_at TEXT NOT NULL,
        log_date TEXT NOT NULL
      )
    ''');
    await db.insert('meal_entries', {
      'food_id': _food.id,
      'food_name': _food.foodName,
      'grams': 150,
      'calories': 247.5,
      'protein': 46.5,
      'carbs': 0,
      'fat': 5.4,
      'logged_at': DateTime(2026, 1, 1).toIso8601String(),
      'log_date': '2026-01-01',
    });

    final repository = MealLogRepositoryImpl(MealLogLocalDataSource(db));
    final entries = await repository.getEntriesForDate('2026-01-01');

    expect(entries.single.amount, 150);
    expect(entries.single.unit, Unit.g);
    expect(entries.single.calories, 247.5);

    await db.close();
  });
}
