import 'package:eating_app/core/units/unit.dart';
import 'package:eating_app/features/nutrition/domain/entities/quantity.dart';
import 'package:eating_app/features/nutrition/domain/usecases/unit_conversion_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('universal weight conversions', () {
    test('1kg -> 1000g', () {
      final grams = UnitConversionService.convertToGrams(
        const Quantity(amount: 1, unit: Unit.kg),
      );
      expect(grams, 1000);
    });

    test('1oz -> 28.3495g', () {
      final grams = UnitConversionService.convertToGrams(
        const Quantity(amount: 1, unit: Unit.oz),
      );
      expect(grams, closeTo(28.3495, 0.0001));
    });

    test('1lb -> 453.592g', () {
      final grams = UnitConversionService.convertToGrams(
        const Quantity(amount: 1, unit: Unit.lb),
      );
      expect(grams, closeTo(453.592, 0.001));
    });
  });

  group('ingredient-specific conversions', () {
    const oliveOilConversions = {Unit.tbsp: 13.6, Unit.tsp: 4.5};

    test('1 tbsp olive oil -> 13.6g', () {
      final grams = UnitConversionService.convertToGrams(
        const Quantity(amount: 1, unit: Unit.tbsp),
        ingredientGramsPerUnit: oliveOilConversions,
      );
      expect(grams, 13.6);
    });

    test('2 tbsp olive oil -> 27.2g', () {
      final grams = UnitConversionService.convertToGrams(
        const Quantity(amount: 2, unit: Unit.tbsp),
        ingredientGramsPerUnit: oliveOilConversions,
      );
      expect(grams, closeTo(27.2, 0.0001));
    });

    test('1 tomato -> 120g, 2 tomatoes -> 240g', () {
      const tomatoConversions = {Unit.piece: 120.0};
      expect(
        UnitConversionService.convertToGrams(
          const Quantity(amount: 1, unit: Unit.piece),
          ingredientGramsPerUnit: tomatoConversions,
        ),
        120,
      );
      expect(
        UnitConversionService.convertToGrams(
          const Quantity(amount: 2, unit: Unit.piece),
          ingredientGramsPerUnit: tomatoConversions,
        ),
        240,
      );
    });

    test('ingredient-specific entry takes priority over a universal one', () {
      // g has a universal factor of 1, but if an ingredient ever had its own
      // override for a weight unit, that override should win.
      final grams = UnitConversionService.convertToGrams(
        const Quantity(amount: 1, unit: Unit.g),
        ingredientGramsPerUnit: const {Unit.g: 2.0},
      );
      expect(grams, 2.0);
    });
  });

  group('missing conversion', () {
    test('returns null instead of inventing a conversion', () {
      final grams = UnitConversionService.convertToGrams(
        const Quantity(amount: 1, unit: Unit.piece),
      );
      expect(grams, isNull);
    });

    test('volume units with no ingredient density return null', () {
      final grams = UnitConversionService.convertToGrams(
        const Quantity(amount: 250, unit: Unit.ml),
      );
      expect(grams, isNull);
    });
  });
}
