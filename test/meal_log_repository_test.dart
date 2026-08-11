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
      grams: 200,
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
      grams: 50,
      calories: updateMacros.calories,
      protein: updateMacros.protein,
      carbs: updateMacros.carbs,
      fat: updateMacros.fat,
    );
    expect(updated.grams, 50);
    expect(updated.calories, closeTo(82.5, 0.001)); // 165 * 50/100

    await repository.deleteEntry(entry.id);
    final afterDelete = await repository.getEntriesForDate('2026-01-01');
    expect(afterDelete, isEmpty);

    await db.close();
  });
}
