import 'unit.dart';

/// The result of parsing a free-text ingredient description like
/// "1 tablespoon of olive oil" into an amount, unit, and the remaining food
/// name. [amount] is null when no leading number could be found (the whole
/// text is then treated as [name]).
class ParsedIngredient {
  const ParsedIngredient({required this.amount, required this.unit, required this.name});

  final double? amount;
  final Unit unit;
  final String name;
}

const _unitAliases = {
  'g': Unit.g, 'gram': Unit.g, 'grams': Unit.g,
  'kg': Unit.kg, 'kilogram': Unit.kg, 'kilograms': Unit.kg,
  'oz': Unit.oz, 'ounce': Unit.oz, 'ounces': Unit.oz,
  'lb': Unit.lb, 'lbs': Unit.lb, 'pound': Unit.lb, 'pounds': Unit.lb,
  'ml': Unit.ml, 'l': Unit.l, 'liter': Unit.l, 'liters': Unit.l,
  'tsp': Unit.tsp, 'teaspoon': Unit.tsp, 'teaspoons': Unit.tsp,
  'tbsp': Unit.tbsp, 'tablespoon': Unit.tbsp, 'tablespoons': Unit.tbsp,
  'cup': Unit.cup, 'cups': Unit.cup,
  'floz': Unit.flOz,
  'piece': Unit.piece, 'pieces': Unit.piece,
};

/// Parses a description such as "1 tablespoon of olive oil" or "200g rice"
/// into `(1, tbsp, "olive oil")` / `(200, g, "rice")`. Falls back to treating
/// the whole text as the ingredient name (with unit defaulting to g) when no
/// number or no recognized unit word is found.
ParsedIngredient parseIngredientText(String raw) {
  var text = raw.trim();
  if (text.isEmpty) return const ParsedIngredient(amount: null, unit: Unit.g, name: '');

  // Normalize multi-word unit phrases to a single token so the one-word
  // unit-matching regex below can find them.
  text = text
      .replaceAll(RegExp(r'\btable\s*spoons?\b', caseSensitive: false), 'tbsp')
      .replaceAll(RegExp(r'\btea\s*spoons?\b', caseSensitive: false), 'tsp')
      .replaceAll(RegExp(r'\bfl\.?\s*oz\b', caseSensitive: false), 'floz');

  final amountMatch = RegExp(r'^([\d]+(?:[.,]\d+)?(?:\s*/\s*\d+)?)\s+(.*)$').firstMatch(text);
  if (amountMatch == null) {
    return ParsedIngredient(amount: null, unit: Unit.g, name: _stripLeadingOf(text));
  }

  final amount = _parseAmount(amountMatch.group(1)!);
  final rest = amountMatch.group(2)!.trim();

  final unitMatch = RegExp(r'^([a-zA-Z]+)\b\s*(.*)$').firstMatch(rest);
  if (unitMatch != null) {
    final alias = _unitAliases[unitMatch.group(1)!.toLowerCase()];
    if (alias != null) {
      final name = _stripLeadingOf(unitMatch.group(2)!.trim());
      if (name.isNotEmpty) return ParsedIngredient(amount: amount, unit: alias, name: name);
    }
  }
  return ParsedIngredient(amount: amount, unit: Unit.g, name: _stripLeadingOf(rest));
}

String _stripLeadingOf(String s) => s.replaceFirst(RegExp(r'^of\s+', caseSensitive: false), '');

double? _parseAmount(String s) {
  final trimmed = s.trim();
  if (trimmed.contains('/')) {
    final parts = trimmed.split('/');
    final numerator = double.tryParse(parts[0].trim().replaceAll(',', '.'));
    final denominator = double.tryParse(parts[1].trim());
    if (numerator != null && denominator != null && denominator != 0) {
      return numerator / denominator;
    }
    return null;
  }
  return double.tryParse(trimmed.replaceAll(',', '.'));
}

/// Formats an amount without a trailing ".0" for whole numbers.
String formatIngredientAmount(double amount) {
  return amount == amount.roundToDouble() ? amount.toInt().toString() : amount.toString();
}
