import '../../features/nutrition/domain/entities/food.dart';

/// A last-resort, keyword-matched reference for converting an ingredient's
/// volume/piece quantity to grams when the food database has no
/// food-specific factor for it (see `food_unit_conversions` via
/// [FoodRepository.getUnitConversions], which is always tried first).
///
/// These density/piece-weight numbers are widely published culinary
/// reference approximations (e.g. baking conversion charts) — they are NOT
/// sourced from CIQUAL and are not nutrition data. They exist only so a
/// handful of extremely common ingredients (honey, milk, an egg, a banana)
/// don't get flagged for every recipe; anything not in this table is
/// flagged for review instead of guessed.
class IngredientReference {
  const IngredientReference({this.gramsPerMl, this.pieceGrams});

  /// Density, for volume units (ml, l, tsp, tbsp, cup, fl oz).
  final double? gramsPerMl;

  /// Average edible weight of one piece, for count units.
  final double? pieceGrams;
}

const _referenceByKeyword = <String, IngredientReference>{
  // Piece weights (edible weight per unit).
  'egg': IngredientReference(pieceGrams: 50),
  'oeuf': IngredientReference(pieceGrams: 50),
  'banana': IngredientReference(pieceGrams: 118),
  'banane': IngredientReference(pieceGrams: 118),
  'apple': IngredientReference(pieceGrams: 182),
  'pomme': IngredientReference(pieceGrams: 182),
  'orange': IngredientReference(pieceGrams: 131),
  'potato': IngredientReference(pieceGrams: 173),
  'pomme de terre': IngredientReference(pieceGrams: 173),
  'tomato': IngredientReference(pieceGrams: 123),
  'tomate': IngredientReference(pieceGrams: 123),
  'onion': IngredientReference(pieceGrams: 110),
  'oignon': IngredientReference(pieceGrams: 110),
  'slice of bread': IngredientReference(pieceGrams: 30),
  'tranche de pain': IngredientReference(pieceGrams: 30),
  'garlic clove': IngredientReference(pieceGrams: 3),
  "gousse d'ail": IngredientReference(pieceGrams: 3),

  // Densities (g/ml), for volume units.
  'honey': IngredientReference(gramsPerMl: 1.42),
  'miel': IngredientReference(gramsPerMl: 1.42),
  'maple syrup': IngredientReference(gramsPerMl: 1.32),
  "sirop d'erable": IngredientReference(gramsPerMl: 1.32),
  'olive oil': IngredientReference(gramsPerMl: 0.92),
  "huile d'olive": IngredientReference(gramsPerMl: 0.92),
  'milk': IngredientReference(gramsPerMl: 1.03),
  'lait': IngredientReference(gramsPerMl: 1.03),
  'cinnamon': IngredientReference(gramsPerMl: 0.56),
  'cannelle': IngredientReference(gramsPerMl: 0.56),
  'vanilla': IngredientReference(gramsPerMl: 0.88),
  'vanille': IngredientReference(gramsPerMl: 0.88),
};

/// Looks up a reference density/piece-weight for [food] by keyword match
/// against its English or French name. Returns null when nothing in the
/// table applies — callers must flag the ingredient rather than guess.
IngredientReference? referenceConversionFor(Food food) {
  final names = [food.foodName.toLowerCase(), food.foodNameFr.toLowerCase()];
  for (final entry in _referenceByKeyword.entries) {
    if (names.any((name) => name.contains(entry.key))) return entry.value;
  }
  return null;
}
