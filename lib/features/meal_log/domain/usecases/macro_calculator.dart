import '../../../../core/units/unit.dart';
import '../../../nutrition/domain/entities/food.dart';
import '../../../nutrition/domain/entities/quantity.dart';
import '../../../nutrition/domain/usecases/unit_conversion_service.dart';

class Macros {
  const Macros({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final double calories;
  final double protein;
  final double carbs;
  final double fat;
}

class MacroCalculator {
  const MacroCalculator._();

  static Macros fromGrams(Food food, double grams) {
    final ratio = grams / 100;
    return Macros(
      calories: (food.caloriesKcal100g ?? 0) * ratio,
      protein: (food.proteinG100g ?? 0) * ratio,
      carbs: (food.carbsG100g ?? 0) * ratio,
      fat: (food.fatG100g ?? 0) * ratio,
    );
  }

  /// Normalizes [quantity] to grams (using [ingredientGramsPerUnit] for
  /// ingredient-specific units, falling back to universal weight
  /// conversion) then computes macros the same way as [fromGrams]. The
  /// caller is expected to only offer units it already knows convert (see
  /// the unit picker in the quantity dialog), so a missing conversion here
  /// is a programming error, not a user-facing case.
  static Macros fromQuantity(
    Food food,
    Quantity quantity, {
    Map<Unit, double> ingredientGramsPerUnit = const {},
  }) {
    final grams = UnitConversionService.convertToGrams(
      quantity,
      ingredientGramsPerUnit: ingredientGramsPerUnit,
    );
    if (grams == null) {
      throw ArgumentError(
        'No conversion available for unit ${quantity.unit.id} on food ${food.id}',
      );
    }
    return fromGrams(food, grams);
  }
}
