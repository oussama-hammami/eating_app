import 'text_normalizer.dart';

/// Grammatical glue words that don't carry food identity — dropped before
/// scoring so they never count for or against a match. Deliberately does
/// NOT include state/prep words like "raw", "plain", "fresh", "cooked" —
/// those distinguish real concepts (see module doc on [FoodMatcher]).
const _stopWords = {'of', 'with', 'and', 'or', 'the', 'a', 'an', 'in', 'on', 'style', 'type'};

/// Common everyday phrasings that share no tokens at all with their CIQUAL
/// name, so no amount of stemming/stopword-dropping would find them —
/// e.g. "rolled oats" and CIQUAL's "Oat, raw" don't have a single word in
/// common. This is intentionally a small, explicit, human-reviewed list
/// (not a guess) covering only cases actually hit in testing; anything not
/// listed here falls through to normal matching and is flagged if nothing
/// is found, rather than silently guessed.
const _phraseSynonyms = {
  'rolled oats': 'oat raw',
  'quick oats': 'oat raw',
  'instant oats': 'oat raw',
  'porridge oats': 'oat raw',
};

/// Splits text into lowercase, accent-folded, singularized, stopword-free
/// tokens for concept-level ingredient matching. Two ingredient names are
/// "the same concept" only if their token sets correspond closely — see
/// [FoodMatcher] for how these tokens are scored against each other.
List<String> tokenizeIngredientText(String text) {
  var normalized = TextNormalizer.normalize(text);
  for (final entry in _phraseSynonyms.entries) {
    normalized = normalized.replaceAll(entry.key, entry.value);
  }
  // Apostrophes are removed (not split on) so "ewe's" -> "ewes", not two
  // tokens ["ewe", "s"]; hyphens/commas/parens do become separators.
  final withoutApostrophes = normalized.replaceAll("'", '');
  final cleaned = withoutApostrophes.replaceAll(RegExp(r'[\-,()]'), ' ');
  final rawTokens = cleaned.split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
  return rawTokens.map(_singularize).where((t) => !_stopWords.contains(t)).toList();
}

/// Best-effort English singularization. Deliberately conservative — a wrong
/// non-singularization (leaving a plural as-is) only costs a little token
/// overlap, but a wrong over-singularization can merge two different words.
String _singularize(String word) {
  if (word.length <= 3) return word;
  if (word.endsWith('ies')) return '${word.substring(0, word.length - 3)}y';
  if (word.endsWith('oes')) return word.substring(0, word.length - 2);
  if (word.endsWith('ves')) return '${word.substring(0, word.length - 3)}f';
  if (word.endsWith('ss') || word.endsWith('us') || word.endsWith('is')) return word;
  if (word.endsWith('s')) return word.substring(0, word.length - 1);
  return word;
}
