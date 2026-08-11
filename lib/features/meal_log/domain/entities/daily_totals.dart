import 'meal_entry.dart';

/// Derived, never persisted — always recomputed from the current day's
/// entries so edits/deletes recalculate instantly with no extra query.
class DailyTotals {
  const DailyTotals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  const DailyTotals.zero()
      : calories = 0,
        protein = 0,
        carbs = 0,
        fat = 0;

  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  factory DailyTotals.fromEntries(List<MealEntry> entries) {
    var calories = 0.0, protein = 0.0, carbs = 0.0, fat = 0.0;
    for (final entry in entries) {
      calories += entry.calories;
      protein += entry.protein;
      carbs += entry.carbs;
      fat += entry.fat;
    }
    return DailyTotals(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );
  }
}
