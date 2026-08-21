class Ingredient {
  Ingredient({
    required this.name,
    required this.quantity,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.fiber,
    this.matchConfidence,
    this.needsConfirmation = false,
  });

  final String name;
  final String quantity;

  /// Nutrition contributed by this ingredient (at its recipe quantity), when
  /// it was matched to a food item with known grams — null otherwise.
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final double? fiber;

  /// How confident [FoodMatcher] was in the food match used to compute the
  /// nutrition above (null if no candidate was found at all).
  final double? matchConfidence;

  /// True when the best food match wasn't confident enough to auto-accept —
  /// nutrition fields are null in that case; a human should confirm which
  /// food was meant instead of trusting a silent guess.
  final bool needsConfirmation;
}
