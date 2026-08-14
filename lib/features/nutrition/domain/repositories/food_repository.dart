import '../../../../core/units/unit.dart';
import '../entities/food.dart';

abstract class FoodRepository {
  /// Case- and accent-insensitive search, prefix matches ranked above
  /// substring matches, each group alphabetically sorted, capped at [limit].
  Future<List<Food>> search(String query, {int limit = 5});

  Future<Food?> getById(int id);

  /// Ingredient-specific unit -> grams-per-unit overrides for this food.
  Future<Map<Unit, double>> getUnitConversions(int foodId);
}
