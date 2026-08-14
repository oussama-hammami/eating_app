import '../../../../core/units/unit.dart';

/// What the user actually entered — amount + unit, preserved verbatim so
/// a recipe/log entry keeps displaying "1 tbsp" rather than the grams it
/// was normalized to for calculation.
class Quantity {
  const Quantity({required this.amount, required this.unit});

  final double amount;
  final Unit unit;
}
