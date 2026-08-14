import '../../../../core/units/unit.dart';
import '../../domain/entities/food.dart';
import '../../domain/repositories/food_repository.dart';
import '../datasources/food_local_data_source.dart';

class FoodRepositoryImpl implements FoodRepository {
  const FoodRepositoryImpl(this._dataSource);

  final FoodLocalDataSource _dataSource;

  @override
  Future<List<Food>> search(String query, {int limit = 5}) =>
      _dataSource.search(query, limit: limit);

  @override
  Future<Food?> getById(int id) => _dataSource.getById(id);

  @override
  Future<Map<Unit, double>> getUnitConversions(int foodId) =>
      _dataSource.getUnitConversions(foodId);
}
