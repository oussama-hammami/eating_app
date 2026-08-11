/// A single logged food entry for a given day, snapshotting the macros
/// computed at log time (so later edits to the CIQUAL data never mutate
/// history).
class MealEntry {
  const MealEntry({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.grams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.loggedAt,
    required this.logDate,
  });

  final int id;
  final int foodId;
  final String foodName;
  final double grams;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime loggedAt;
  final String logDate;

  MealEntry copyWith({
    double? grams,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
  }) {
    return MealEntry(
      id: id,
      foodId: foodId,
      foodName: foodName,
      grams: grams ?? this.grams,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      loggedAt: loggedAt,
      logDate: logDate,
    );
  }
}
