import '../../../../core/units/unit.dart';
import '../../../nutrition/domain/entities/food.dart';
import '../../../nutrition/domain/entities/quantity.dart';
import '../entities/meal_entry.dart';
import '../repositories/meal_log_repository.dart';
import 'macro_calculator.dart';

class AddMealEntry {
  const AddMealEntry(this._repository);

  final MealLogRepository _repository;

  Future<MealEntry> call({
    required Food food,
    required Quantity quantity,
    Map<Unit, double> ingredientGramsPerUnit = const {},
    required String logDate,
    required DateTime loggedAt,
    required String languageCode,
  }) {
    final macros = MacroCalculator.fromQuantity(
      food,
      quantity,
      ingredientGramsPerUnit: ingredientGramsPerUnit,
    );
    return _repository.addEntry(
      foodId: food.id,
      foodName: food.displayName(languageCode),
      amount: quantity.amount,
      unit: quantity.unit,
      calories: macros.calories,
      protein: macros.protein,
      carbs: macros.carbs,
      fat: macros.fat,
      logDate: logDate,
      loggedAt: loggedAt,
    );
  }
}
