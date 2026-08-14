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
  ml('ml', UnitCategory.volume, mlPerBaseUnit: 1),
  l('l', UnitCategory.volume, mlPerBaseUnit: 1000),
  tsp('tsp', UnitCategory.volume, mlPerBaseUnit: 4.92892),
  tbsp('tbsp', UnitCategory.volume, mlPerBaseUnit: 14.7868),
  cup('cup', UnitCategory.volume, mlPerBaseUnit: 236.588),
  flOz('fl_oz', UnitCategory.volume, mlPerBaseUnit: 29.5735),
  piece('piece', UnitCategory.count);

  const Unit(this.id, this.category, {this.gramsPerBaseUnit, this.mlPerBaseUnit});

  /// Stable persisted identifier — never translated.
  final String id;
  final UnitCategory category;

  /// Universal conversion factor to grams, only defined for [UnitCategory.weight]
  /// units. Volume and count units always depend on the specific ingredient
  /// (density/piece weight), so they have no universal factor.
  final double? gramsPerBaseUnit;

  /// Universal conversion factor to milliliters, only defined for
  /// [UnitCategory.volume] units. Still needs a food's density to become
  /// grams.
  final double? mlPerBaseUnit;

  static Unit fromId(String id) =>
      Unit.values.firstWhere((u) => u.id == id, orElse: () => Unit.g);
}
