import 'food.dart';

/// Average weight (grams) of a single "piece" for common foods, keyed by a
/// lowercase keyword matched against the food's name. Not sourced from
/// CIQUAL — there is no universal factor for "piece" (unlike weight/volume
/// units), so this is a best-effort approximation for the common cases.
/// Returns null when no match is found — callers should skip the ingredient
/// from nutrition totals in that case rather than guess.
const Map<String, double> _pieceGramsByKeyword = {
  'egg': 50,
  'oeuf': 50,
  'banana': 118,
  'banane': 118,
  'apple': 182,
  'pomme': 182,
  'orange': 131,
  'potato': 173,
  'pomme de terre': 173,
  'tomato': 123,
  'tomate': 123,
  'onion': 110,
  'oignon': 110,
  'slice of bread': 30,
  'tranche de pain': 30,
  'garlic clove': 3,
  'gousse d\'ail': 3,
};

double? pieceGramsFor(Food food) {
  final names = [food.foodName.toLowerCase(), food.foodNameFr.toLowerCase()];
  for (final entry in _pieceGramsByKeyword.entries) {
    if (names.any((name) => name.contains(entry.key))) return entry.value;
  }
  return null;
}
