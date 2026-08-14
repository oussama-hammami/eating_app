/// Centralized measurement unit system. Internal identifiers (`id`) are
/// stable and locale-independent — they're what gets persisted to the
/// database and matched against ingredient-specific conversions. Display
/// labels are localized separately (see `AppLocalizations`), never stored.
enum UnitCategory { weight, volume, count }

enum Unit {
  g('g', UnitCategory.weight, gramsPerBaseUnit: 1),
  kg('kg', UnitCategory.weight, gramsPerBaseUnit: 1000),
  oz('oz', UnitCategory.weight, gramsPerBaseUnit: 28.3495),
  lb('lb', UnitCategory.weight, gramsPerBaseUnit: 453.592),
  ml('ml', UnitCategory.volume),
  l('l', UnitCategory.volume),
  tsp('tsp', UnitCategory.volume),
  tbsp('tbsp', UnitCategory.volume),
  cup('cup', UnitCategory.volume),
  flOz('fl_oz', UnitCategory.volume),
  piece('piece', UnitCategory.count);

  const Unit(this.id, this.category, {this.gramsPerBaseUnit});

  /// Stable persisted identifier — never translated.
  final String id;
  final UnitCategory category;

  /// Universal conversion factor to grams, only defined for [UnitCategory.weight]
  /// units. Volume and count units always depend on the specific ingredient
  /// (density/piece weight), so they have no universal factor.
  final double? gramsPerBaseUnit;

  static Unit fromId(String id) =>
      Unit.values.firstWhere((u) => u.id == id, orElse: () => Unit.g);
}
