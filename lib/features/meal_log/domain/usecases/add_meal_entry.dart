import '../../../nutrition/domain/entities/food.dart';
import '../entities/meal_entry.dart';
import '../repositories/meal_log_repository.dart';
import 'macro_calculator.dart';

class AddMealEntry {
  const AddMealEntry(this._repository);

  final MealLogRepository _repository;

  Future<MealEntry> call({
    required Food food,
    required double grams,
    required String logDate,
    required DateTime loggedAt,
  }) {
    final macros = MacroCalculator.fromGrams(food, grams);
    return _repository.addEntry(
      foodId: food.id,
      foodName: food.foodName,
      grams: grams,
      calories: macros.calories,
      protein: macros.protein,
      carbs: macros.carbs,
      fat: macros.fat,
      logDate: logDate,
      loggedAt: loggedAt,
    );
  }
}
