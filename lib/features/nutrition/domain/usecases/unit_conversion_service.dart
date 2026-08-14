import '../../../../core/units/unit.dart';
import '../entities/quantity.dart';

/// Resolves a [Quantity] to grams. Resolution order:
///  1. Ingredient-specific conversion (from [ingredientGramsPerUnit]) —
///     required for anything that isn't a plain weight unit, since volume
///     (density) and count (piece weight) are ingredient-dependent.
///  2. Universal weight conversion (g/kg/oz/lb) — same for every ingredient.
///  3. No conversion available — returns null rather than guessing.
class UnitConversionService {
  const UnitConversionService._();

  static double? convertToGrams(
    Quantity quantity, {
    Map<Unit, double> ingredientGramsPerUnit = const {},
  }) {
    final specific = ingredientGramsPerUnit[quantity.unit];
    if (specific != null) return quantity.amount * specific;

    final universal = quantity.unit.gramsPerBaseUnit;
    if (universal != null) return quantity.amount * universal;

    return null;
  }
}
