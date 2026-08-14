import 'package:eating_app/core/units/unit.dart';
import 'package:eating_app/features/meal_log/domain/entities/daily_totals.dart';
import 'package:eating_app/features/meal_log/domain/entities/meal_entry.dart';
import 'package:flutter_test/flutter_test.dart';

MealEntry _entry({
  required int id,
  required double calories,
  required double protein,
  required double carbs,
  required double fat,
}) {
  return MealEntry(
    id: id,
    foodId: id,
    foodName: 'Food $id',
    amount: 100,
    unit: Unit.g,
    calories: calories,
    protein: protein,
    carbs: carbs,
    fat: fat,
    loggedAt: DateTime(2026, 1, 1),
    logDate: '2026-01-01',
  );
}

void main() {
  test('zero entries yields zero totals', () {
    final totals = DailyTotals.fromEntries(const []);
    expect(totals.calories, 0);
    expect(totals.protein, 0);
  });

  test('sums macros across entries', () {
    final entries = [
      _entry(id: 1, calories: 100, protein: 10, carbs: 20, fat: 5),
      _entry(id: 2, calories: 200, protein: 15, carbs: 25, fat: 8),
    ];
    final totals = DailyTotals.fromEntries(entries);
    expect(totals.calories, 300);
    expect(totals.protein, 25);
    expect(totals.carbs, 45);
    expect(totals.fat, 13);
  });

  test('recomputes correctly after removing an entry', () {
    final entries = [
      _entry(id: 1, calories: 100, protein: 10, carbs: 20, fat: 5),
      _entry(id: 2, calories: 200, protein: 15, carbs: 25, fat: 8),
    ];
    final afterDelete = entries.where((e) => e.id != 1).toList();
    final totals = DailyTotals.fromEntries(afterDelete);
    expect(totals.calories, 200);
    expect(totals.protein, 15);
  });
}
