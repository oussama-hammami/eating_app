/// Scales a quantity string like "200 g" by [factor] (e.g. planned servings
/// ÷ recipe portions), returning "300 g" for factor 1.5. Quantities that
/// don't start with a number (e.g. "a pinch") are returned unchanged — there
/// is nothing numeric to scale.
String scaleQuantity(String raw, double factor) {
  final quantity = raw.trim();
  if (quantity.isEmpty || factor == 1) return quantity;

  final match = RegExp(r'^([\d.]+)\s*(.*)$').firstMatch(quantity);
  if (match == null) return quantity;

  final amount = double.tryParse(match.group(1)!);
  if (amount == null) return quantity;

  final unit = match.group(2)!.trim();
  final scaled = amount * factor;
  final amountText = scaled == scaled.roundToDouble()
      ? scaled.toInt().toString()
      : scaled.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  return unit.isEmpty ? amountText : '$amountText $unit';
}
