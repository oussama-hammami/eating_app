import '../entities/food.dart';
import '../repositories/food_repository.dart';

class SearchFoods {
  const SearchFoods(this._repository);

  final FoodRepository _repository;

  Future<List<Food>> call(String query, {int limit = 5}) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return Future.value(const []);
    return _repository.search(trimmed, limit: limit);
  }
}
