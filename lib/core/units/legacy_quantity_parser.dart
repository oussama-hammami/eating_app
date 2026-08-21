import 'unit.dart';

const _unitAliases = {
  'g': Unit.g, 'gram': Unit.g, 'grams': Unit.g,
  'kg': Unit.kg, 'kilogram': Unit.kg, 'kilograms': Unit.kg,
  'oz': Unit.oz, 'ounce': Unit.oz, 'ounces': Unit.oz,
  'lb': Unit.lb, 'lbs': Unit.lb, 'pound': Unit.lb, 'pounds': Unit.lb,
  'ml': Unit.ml, 'l': Unit.l, 'liter': Unit.l, 'liters': Unit.l,
  'tsp': Unit.tsp, 'teaspoon': Unit.tsp, 'teaspoons': Unit.tsp,
  'tbsp': Unit.tbsp, 'tablespoon': Unit.tbsp, 'tablespoons': Unit.tbsp,
  'cup': Unit.cup, 'cups': Unit.cup,
  'fl oz': Unit.flOz, 'fl_oz': Unit.flOz,
  'piece': Unit.piece, 'pieces': Unit.piece, '': Unit.g,
};

/// Splits a legacy, name-less free-text quantity like "2 cups" into a
/// numeric amount and its best-guess [Unit], falling back to the whole
/// string as the amount with [Unit.g] when no unit can be recognized.
///
/// Distinct from [parseIngredientText] (in ingredient_text_parser.dart),
/// which parses a *full* description like "1 tablespoon of olive oil" that
/// also carries a food name — this one only ever sees a bare quantity.
(String amount, Unit unit) parseLegacyQuantity(String raw) {
  final match = RegExp(r'^([\d.]+)\s*(.*)$').firstMatch(raw.trim());
  if (match == null) return (raw.trim(), Unit.g);
  final amount = match.group(1)!;
  final unitText = match.group(2)!.trim().toLowerCase();
  return (amount, _unitAliases[unitText] ?? Unit.g);
}
