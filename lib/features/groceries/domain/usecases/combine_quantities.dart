/// Combines quantity strings like "2 cups" + "1 cups" into "3 cups".
/// Quantities that don't share a numeric+unit format are kept as separate
/// entries joined with "+".
String combineQuantities(List<String> quantities) {
  final quantityPattern = RegExp(r'^([\d.]+)\s*(.*)$');
  double? numericAmount;
  String? unit;
  final extras = <String>[];

  for (final raw in quantities) {
    final quantity = raw.trim();
    if (quantity.isEmpty) continue;
    final match = quantityPattern.firstMatch(quantity);
    if (match != null) {
      final amount = double.tryParse(match.group(1)!);
      final matchedUnit = match.group(2)!.trim().toLowerCase();
      if (amount != null && (unit == null || unit == matchedUnit)) {
        unit = matchedUnit;
        numericAmount = (numericAmount ?? 0) + amount;
        continue;
      }
    }
    extras.add(quantity);
  }

  final parts = <String>[];
  if (numericAmount != null) {
    final amountText = numericAmount == numericAmount.roundToDouble()
        ? numericAmount.toInt().toString()
        : numericAmount.toString();
    parts.add(unit!.isEmpty ? amountText : '$amountText $unit');
  }
  parts.addAll(extras);
  return parts.join(' + ');
}
