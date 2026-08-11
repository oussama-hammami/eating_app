import '../../../nutrition/domain/entities/food.dart';

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
}
