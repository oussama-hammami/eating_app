import '../../../nutrition/domain/entities/food.dart';
import '../entities/meal_entry.dart';
import '../repositories/meal_log_repository.dart';
import 'macro_calculator.dart';

class UpdateMealEntry {
  const UpdateMealEntry(this._repository);

  final MealLogRepository _repository;

  Future<MealEntry> call({
    required MealEntry entry,
    required Food food,
    required double grams,
  }) {
    final macros = MacroCalculator.fromGrams(food, grams);
    return _repository.updateEntry(
      entryId: entry.id,
      grams: grams,
      calories: macros.calories,
      protein: macros.protein,
      carbs: macros.carbs,
      fat: macros.fat,
    );
  }
}
