import '../../../../core/units/ingredient_conversion_table.dart';
import '../../../../core/units/unit.dart';
import '../entities/food.dart';
import '../entities/quantity.dart';
import '../repositories/food_repository.dart';
import 'unit_conversion_service.dart';

/// How [GramsConversion.grams] was derived, in order of preference.
enum ConversionMethod {
  /// g/kg/oz/lb — an exact, universal, ingredient-independent factor.
  weightExact,

  /// A food-specific factor from the database's `food_unit_conversions`
  /// table (e.g. "1 tbsp of this specific olive oil = 13.6 g"). Preferred
  /// over any generic density/piece-weight assumption.
  databaseExact,

  /// A keyword-matched density/piece-weight from [referenceConversionFor] —
  /// a culinary reference approximation, not sourced from the food
  /// database itself.
  referenceApprox,

  /// No reliable conversion was found. [GramsConversion.grams] is null —
  /// callers must surface this rather than silently assume a density.
  unresolvedFlagged,
}

/// The result of converting one ingredient's amount+unit to grams, with
/// full provenance for debugging/auditing.
class GramsConversion {
  const GramsConversion({
    required this.grams,
    required this.method,
    required this.factorUsed,
    required this.note,
  });

  final double? grams;
  final ConversionMethod method;
  final double? factorUsed;
  final String note;

  bool get isFlagged => method == ConversionMethod.unresolvedFlagged;
}

/// Converts [amount] [unit] of [food] to grams, preferring (in order):
/// 1. An exact universal weight-unit factor (g/kg/oz/lb).
/// 2. A food-specific factor from the database (`food_unit_conversions`).
/// 3. A keyword-matched reference density/piece-weight approximation.
/// 4. Flagged as unresolved — never silently assumes density = 1.0 (water).
Future<GramsConversion> convertIngredientToGrams({
  required FoodRepository repository,
  required Food food,
  required double amount,
  required Unit unit,
}) async {
  if (unit.category == UnitCategory.weight) {
    final grams = UnitConversionService.convertToGrams(Quantity(amount: amount, unit: unit))!;
    return GramsConversion(
      grams: grams,
      method: ConversionMethod.weightExact,
      factorUsed: unit.gramsPerBaseUnit,
      note: 'exact weight-unit conversion (${unit.id} -> g)',
    );
  }

  final dbConversions = await repository.getUnitConversions(food.id);
  final dbGrams = UnitConversionService.convertToGrams(
    Quantity(amount: amount, unit: unit),
    ingredientGramsPerUnit: dbConversions,
  );
  if (dbGrams != null) {
    return GramsConversion(
      grams: dbGrams,
      method: ConversionMethod.databaseExact,
      factorUsed: dbConversions[unit],
      note: 'food-specific factor from food_unit_conversions for "${food.foodName}"',
    );
  }

  final reference = referenceConversionFor(food);
  if (unit.category == UnitCategory.volume && reference?.gramsPerMl != null) {
    final ml = amount * unit.mlPerBaseUnit!;
    final density = reference!.gramsPerMl!;
    return GramsConversion(
      grams: ml * density,
      method: ConversionMethod.referenceApprox,
      factorUsed: density,
      note: 'reference density approximation (g/ml), not from the food database',
    );
  }
  if (unit.category == UnitCategory.count && reference?.pieceGrams != null) {
    final pieceGrams = reference!.pieceGrams!;
    return GramsConversion(
      grams: amount * pieceGrams,
      method: ConversionMethod.referenceApprox,
      factorUsed: pieceGrams,
      note: 'reference piece-weight approximation, not from the food database',
    );
  }

  return GramsConversion(
    grams: null,
    method: ConversionMethod.unresolvedFlagged,
    factorUsed: null,
    note: 'no database or reference conversion available for '
        '"${food.foodName}" in ${unit.id} — flagged instead of assuming a density',
  );
}
