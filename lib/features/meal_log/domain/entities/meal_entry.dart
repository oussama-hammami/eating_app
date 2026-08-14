import '../../../../core/units/unit.dart';
import '../../../nutrition/domain/entities/quantity.dart';

/// A single logged food entry for a given day, snapshotting the macros
/// computed at log time (so later edits to the CIQUAL data never mutate
/// history). [amount]/[unit] preserve what the user actually entered (e.g.
/// "1 tbsp") — grams are only an internal detail of how macros were derived.
class MealEntry {
  const MealEntry({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.amount,
    required this.unit,
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
  final double amount;
  final Unit unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime loggedAt;
  final String logDate;

  Quantity get quantity => Quantity(amount: amount, unit: unit);

  MealEntry copyWith({
    double? amount,
    Unit? unit,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
  }) {
    return MealEntry(
      id: id,
      foodId: foodId,
      foodName: foodName,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      loggedAt: loggedAt,
      logDate: logDate,
    );
  }
}
