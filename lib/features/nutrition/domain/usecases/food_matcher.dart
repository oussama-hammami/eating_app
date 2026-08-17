import '../../../../core/text/ingredient_tokenizer.dart';
import '../entities/food.dart';
import '../repositories/food_repository.dart';

/// One scored candidate for an ingredient name.
///
/// [confidence] is a 0..1 concept-overlap score (see [FoodMatcher._score]),
/// not a probability — it measures how completely the candidate's name
/// covers what the user asked for, penalized for anything the candidate
/// adds that the user didn't ask for. [reason] is a short human-readable
/// audit trail explaining exactly why the score came out that way.
class FoodMatch {
  const FoodMatch({required this.food, required this.confidence, required this.reason});

  final Food food;
  final double confidence;
  final String reason;
}

/// All scored candidates for one ingredient name, ranked highest-confidence
/// first, already filtered to [FoodMatcher.candidateThreshold] and above.
class FoodMatchResult {
  const FoodMatchResult({required this.query, required this.candidates});

  final String query;
  final List<FoodMatch> candidates;

  FoodMatch? get best => candidates.isEmpty ? null : candidates.first;

  /// True when there is no candidate confident enough to silently accept,
  /// OR when the top candidate isn't clearly ahead of the runner-up —
  /// e.g. "vanilla extract" ties equally between "Vanilla, alcoholic
  /// extract" (240 kcal/100g) and "Vanilla, aqueous extract" (57.7
  /// kcal/100g): both cover the query with exactly one free qualifier, so
  /// they score identically, but they are NOT the same product. Silently
  /// picking whichever happens to sort first would be exactly the kind of
  /// guess this pipeline exists to avoid. Callers must not use [best]
  /// as-is when this is true; they should surface [candidates] for the
  /// user (or caller) to confirm instead.
  bool get needsConfirmation {
    final topMatch = best;
    if (topMatch == null || topMatch.confidence < FoodMatcher.autoAcceptThreshold) return true;
    if (candidates.length < 2) return false;
    final runnerUp = candidates[1];
    return (topMatch.confidence - runnerUp.confidence) < FoodMatcher.tieMargin;
  }
}

/// Matches a free-text ingredient name to food-database entries by
/// concept-level token overlap, instead of the old "first search result
/// wins" approach that silently matched "Greek yogurt" to "Yogurt,
/// Greek-style, ewe's milk" and "vanilla extract" to "Vanilla, pod".
///
/// Scoring is deliberately conservative: a candidate only auto-accepts
/// ([FoodMatchResult.needsConfirmation] == false) when its name's tokens
/// are almost entirely comprised of what the user asked for — extra
/// qualifying words the user didn't mention (a milk type, a prep method,
/// an unrelated modifier) count against it, and it's the responsibility of
/// [FoodMatcher.autoAcceptThreshold] to keep that conservative.
class FoodMatcher {
  const FoodMatcher(this._repository);

  final FoodRepository _repository;

  /// A candidate at or above this confidence can be used without asking
  /// for confirmation. Deliberately high — reaching it requires covering
  /// every query token and having very few unrequested extra tokens.
  static const autoAcceptThreshold = 0.82;

  /// How close the runner-up's confidence can be to the best match's
  /// before they're considered tied (see [FoodMatchResult.needsConfirmation]).
  static const tieMargin = 0.05;

  /// Candidates below this confidence are dropped entirely rather than
  /// surfaced as a weak alternative — they share too little with the query
  /// to be a useful suggestion at all.
  static const candidateThreshold = 0.35;

  // The underlying SQL search ranks prefix matches alphabetically by
  // food_name (with its original punctuation), which puts a canonical
  // entry like "Egg, raw" (comma right after the head noun) BEHIND
  // "Egg custard", "Egg roll", etc. (space right after the head noun) —
  // comma sorts after space in ASCII. Scoring is what's supposed to pick
  // the true winner, not SQL's alphabetical order, so the candidate pool
  // needs to be wide enough that a same-prefix canonical entry isn't
  // truncated away before it ever reaches the scorer.
  static const defaultCandidatePoolSize = 40;

  Future<FoodMatchResult> match(
    String ingredientName, {
    int candidatePoolSize = defaultCandidatePoolSize,
  }) async {
    final queryTokens = tokenizeIngredientText(ingredientName);
    if (queryTokens.isEmpty) {
      return FoodMatchResult(query: ingredientName, candidates: const []);
    }

    // Search using the normalized/singularized tokens, not the raw text —
    // the database is singular ("Egg, raw"), so a plural query ("eggs")
    // must be singularized before hitting SQL or it never even reaches the
    // scoring step (LIKE 'eggs%' doesn't match "egg raw...").
    final pool = await _repository.search(queryTokens.join(' '), limit: candidatePoolSize);
    final scored = <FoodMatch>[];
    for (final food in pool) {
      final match = _score(queryTokens, food);
      if (match.confidence >= candidateThreshold) scored.add(match);
    }
    scored.sort((a, b) => b.confidence.compareTo(a.confidence));
    return FoodMatchResult(query: ingredientName, candidates: scored);
  }

  FoodMatch _score(List<String> queryTokens, Food food) {
    final english = _scoreAgainstName(queryTokens, food.foodName);
    if (food.foodNameFr.isEmpty) return FoodMatch(food: food, confidence: english.$1, reason: english.$2);
    final french = _scoreAgainstName(queryTokens, food.foodNameFr);
    return french.$1 > english.$1
        ? FoodMatch(food: food, confidence: french.$1, reason: '${french.$2} (fr name)')
        : FoodMatch(food: food, confidence: english.$1, reason: english.$2);
  }

  (double, String) _scoreAgainstName(List<String> queryTokens, String candidateName) {
    final querySet = queryTokens.toSet();
    final candidateTokens = tokenizeIngredientText(candidateName);
    final candidateSet = candidateTokens.toSet();
    if (candidateSet.isEmpty) return (0.0, 'candidate has no comparable tokens');

    final overlap = querySet.intersection(candidateSet);
    if (overlap.isEmpty) return (0.0, 'no shared words with "$candidateName"');

    final coverage = overlap.length / querySet.length;
    final missing = querySet.difference(candidateSet);
    final totalExtra = candidateSet.difference(querySet);

    // Extra tokens are penalized differently depending on WHERE they sit
    // relative to the first requested concept. Words appearing before it
    // ("leading") mean the candidate is fundamentally about something else
    // first — e.g. "Marsala with eggs" for the query "eggs": "Marsala"
    // precedes "eggs", signaling a Marsala dish that merely contains egg,
    // not egg itself. Those get the full penalty, no allowance. Words
    // at/after the first match ("trailing") are CIQUAL's normal qualifier-
    // suffix pattern ("Egg, raw", "Vanilla, alcoholic extract", "Yogurt,
    // Greek-style, ewe's milk") — extremely common and usually an implied
    // default, so the first one is free; a second is what starts to signal
    // a narrower/different product (e.g. Greek yogurt's "ewe" AND "milk").
    final earliestMatch = candidateTokens.indexWhere(querySet.contains);
    final leadingTokens = candidateTokens.sublist(0, earliestMatch).toSet();
    final leadingExtra = totalExtra.intersection(leadingTokens);
    final trailingExtra = totalExtra.difference(leadingExtra);

    final leadingRatio = leadingExtra.length / candidateSet.length;
    const freeTrailingAllowance = 1;
    final excessTrailing = trailingExtra.length > freeTrailingAllowance
        ? trailingExtra.length - freeTrailingAllowance
        : 0;
    final trailingRatio = excessTrailing / candidateSet.length;

    final confidence = (coverage - leadingRatio * 0.9 - trailingRatio * 0.9).clamp(0.0, 1.0);

    final parts = <String>[
      'matched [${overlap.join(', ')}]',
      if (missing.isNotEmpty) 'missing [${missing.join(', ')}]',
      if (leadingExtra.isNotEmpty) 'leading extra [${leadingExtra.join(', ')}] — different concept',
      if (trailingExtra.isNotEmpty) 'trailing extra [${trailingExtra.join(', ')}] not requested',
    ];
    final reason = parts.join('; ');

    return (confidence, reason);
  }
}
