import '../../../../core/units/unit.dart';
import '../../../nutrition/domain/entities/food.dart';
import '../../../nutrition/domain/entities/quantity.dart';
import '../entities/meal_entry.dart';
import '../repositories/meal_log_repository.dart';
import 'macro_calculator.dart';

class UpdateMealEntry {
  const UpdateMealEntry(this._repository);

  final MealLogRepository _repository;

  Future<MealEntry> call({
    required MealEntry entry,
    required Food food,
    required Quantity quantity,
    Map<Unit, double> ingredientGramsPerUnit = const {},
  }) {
    final macros = MacroCalculator.fromQuantity(
      food,
      quantity,
      ingredientGramsPerUnit: ingredientGramsPerUnit,
    );
    return _repository.updateEntry(
      entryId: entry.id,
      amount: quantity.amount,
      unit: quantity.unit,
      calories: macros.calories,
      protein: macros.protein,
      carbs: macros.carbs,
      fat: macros.fat,
    );
  }
}
