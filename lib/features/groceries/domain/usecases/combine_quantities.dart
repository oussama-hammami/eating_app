/// Matches a leading numeric amount — a whole number, a decimal, a simple
/// fraction ("1/2"), or a mixed number ("1 1/2") — followed by an optional
/// unit. The mixed-number alternative must come first so "1 1/2 cup" isn't
/// misparsed as "1" leaving "1/2 cup" in the unit portion.
final _quantityPattern =
    RegExp(r'^(\d+\s+\d+/\d+|\d+/\d+|\d+(?:\.\d+)?)\s*(.*)$');

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

/// Strips a simple trailing plural "s" so "cups" and "cup" combine as the
/// same unit. Doesn't touch short units or ones already ending in "ss".
String _normalizeUnit(String unit) {
  if (unit.length > 3 && unit.endsWith('s') && !unit.endsWith('ss')) {
    return unit.substring(0, unit.length - 1);
  }
  return unit;
}

String _formatAmount(double amount) {
  return amount == amount.roundToDouble()
      ? amount.toInt().toString()
      : amount.toString();
}

/// Combines quantity strings like "2 cups" + "1 cups" into "3 cups".
/// Quantities with a numeric amount and a unit are summed per-unit (e.g.
/// "2 cups" + "200 g" combines into "2 cups + 200 g" instead of listing each
/// occurrence separately). Quantities that don't share a numeric+unit format
/// are kept as separate entries joined with "+".
String combineQuantities(List<String> quantities) {
  final unitTotals = <String, double>{};
  final unitDisplay = <String, String>{};
  final extras = <String>[];

  for (final raw in quantities) {
    final quantity = raw.trim();
    if (quantity.isEmpty) continue;
    final match = _quantityPattern.firstMatch(quantity);
    if (match != null) {
      final amount = _parseAmount(match.group(1)!);
      final displayUnit = match.group(2)!.trim().toLowerCase();
      final normalizedUnit = _normalizeUnit(displayUnit);
      if (amount != null) {
        unitTotals[normalizedUnit] = (unitTotals[normalizedUnit] ?? 0) + amount;
        unitDisplay.putIfAbsent(normalizedUnit, () => displayUnit);
        continue;
      }
    }
    extras.add(quantity);
  }

  final parts = <String>[
    for (final entry in unitTotals.entries)
      entry.key.isEmpty
          ? _formatAmount(entry.value)
          : '${_formatAmount(entry.value)} ${unitDisplay[entry.key]}',
    ...extras,
  ];
  return parts.join(' + ');
}
