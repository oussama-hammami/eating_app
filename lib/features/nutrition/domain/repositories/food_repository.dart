import '../entities/food.dart';

abstract class FoodRepository {
  /// Case- and accent-insensitive search, prefix matches ranked above
  /// substring matches, each group alphabetically sorted, capped at [limit].
  Future<List<Food>> search(String query, {int limit = 5});

  Future<Food?> getById(int id);
}
