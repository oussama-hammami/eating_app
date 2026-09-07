double? _parseFraction(String text) {
  final segments = text.split('/');
  if (segments.length != 2) return null;
  final numerator = double.tryParse(segments[0]);
  final denominator = double.tryParse(segments[1]);
  if (numerator == null || denominator == null || denominator == 0) {
    return null;
  }
  return numerator / denominator;
}

double? _parseAmount(String amountText) {
  if (amountText.contains(' ')) {
    final parts = amountText.split(' ');
    final whole = double.tryParse(parts[0]);
    final fraction = _parseFraction(parts[1]);
    if (whole == null || fraction == null) return null;
    return whole + fraction;
  }
  if (amountText.contains('/')) return _parseFraction(amountText);
  return double.tryParse(amountText);
}

/// Scales a quantity string like "200 g" by [factor] (e.g. planned servings
/// ÷ recipe portions), returning "300 g" for factor 1.5. Quantities that
/// don't start with a number (e.g. "a pinch") are returned unchanged — there
/// is nothing numeric to scale.
String scaleQuantity(String raw, double factor) {
  final quantity = raw.trim();
  if (quantity.isEmpty || factor == 1) return quantity;

  final match = RegExp(r'^(\d+\s+\d+/\d+|\d+/\d+|\d+(?:\.\d+)?)\s*(.*)$')
      .firstMatch(quantity);
  if (match == null) return quantity;

  final amount = _parseAmount(match.group(1)!);
  if (amount == null) return quantity;

  final unit = match.group(2)!.trim();
  final scaled = amount * factor;
  final amountText = scaled == scaled.roundToDouble()
      ? scaled.toInt().toString()
      : scaled.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  return unit.isEmpty ? amountText : '$amountText $unit';
}
