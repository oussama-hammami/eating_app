/// A food item and its nutrition values per 100g, as sourced from CIQUAL.
class Food {
  const Food({
    required this.id,
    required this.foodName,
    this.foodNameFr = '',
    required this.caloriesKcal100g,
    required this.proteinG100g,
    required this.carbsG100g,
    required this.fatG100g,
    required this.fiberG100g,
  });

  final int id;
  final String foodName;
  final String foodNameFr;

  String displayName(String languageCode) =>
      languageCode == 'fr' && foodNameFr.isNotEmpty ? foodNameFr : foodName;
  final double? caloriesKcal100g;
  final double? proteinG100g;
  final double? carbsG100g;
  final double? fatG100g;
  final double? fiberG100g;

  @override
  bool operator ==(Object other) => other is Food && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
