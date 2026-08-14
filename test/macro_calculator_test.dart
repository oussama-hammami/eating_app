import 'package:eating_app/core/units/unit.dart';
import 'package:eating_app/features/meal_log/domain/usecases/macro_calculator.dart';
import 'package:eating_app/features/nutrition/domain/entities/food.dart';
import 'package:eating_app/features/nutrition/domain/entities/quantity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const food = Food(
    id: 1,
    foodName: 'Test food',
    caloriesKcal100g: 200,
    proteinG100g: 20,
    carbsG100g: 10,
    fatG100g: 5,
    fiberG100g: 2,
  );

  test('scales macros linearly with grams / 100', () {
    final macros = MacroCalculator.fromGrams(food, 150);
    expect(macros.calories, 300);
    expect(macros.protein, 30);
    expect(macros.carbs, 15);
    expect(macros.fat, 7.5);
  });

  test('treats null per-100g values as zero', () {
    const foodWithNulls = Food(
      id: 2,
      foodName: 'Sparse food',
      caloriesKcal100g: null,
      proteinG100g: null,
      carbsG100g: null,
      fatG100g: null,
      fiberG100g: null,
    );
    final macros = MacroCalculator.fromGrams(foodWithNulls, 100);
    expect(macros.calories, 0);
    expect(macros.protein, 0);
    expect(macros.carbs, 0);
    expect(macros.fat, 0);
  });

  test('zero grams yields zero macros', () {
    final macros = MacroCalculator.fromGrams(food, 0);
    expect(macros.calories, 0);
  });

  test('fromQuantity resolves a universal weight unit before computing', () {
    final macros = MacroCalculator.fromQuantity(
      food,
      const Quantity(amount: 1, unit: Unit.kg),
    );
    expect(macros.calories, 2000); // 200 * 1000g/100
  });

  test('fromQuantity uses ingredient-specific conversion for olive-oil-like tbsp', () {
    final macros = MacroCalculator.fromQuantity(
      food,
      const Quantity(amount: 1, unit: Unit.tbsp),
      ingredientGramsPerUnit: const {Unit.tbsp: 13.6},
    );
    expect(macros.calories, closeTo(27.2, 0.001)); // 200 * 13.6/100
  });

  test('fromQuantity throws for a unit with no available conversion', () {
    expect(
      () => MacroCalculator.fromQuantity(food, const Quantity(amount: 1, unit: Unit.piece)),
      throwsArgumentError,
    );
  });
}
