import '../../domain/entities/meal_entry.dart';
import '../../domain/repositories/meal_log_repository.dart';
import '../datasources/meal_log_local_data_source.dart';
import '../models/meal_entry_model.dart';

class MealLogRepositoryImpl implements MealLogRepository {
  const MealLogRepositoryImpl(this._dataSource);

  final MealLogLocalDataSource _dataSource;

  @override
  Future<List<MealEntry>> getEntriesForDate(String logDate) =>
      _dataSource.getEntriesForDate(logDate);

  @override
  Future<MealEntry> addEntry({
    required int foodId,
    required String foodName,
    required double grams,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required String logDate,
    required DateTime loggedAt,
  }) {
    return _dataSource.insert(
      MealEntryModel(
        id: 0,
        foodId: foodId,
        foodName: foodName,
        grams: grams,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        loggedAt: loggedAt,
        logDate: logDate,
      ),
    );
  }

  @override
  Future<MealEntry> updateEntry({
    required int entryId,
    required double grams,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    await _dataSource.update(
      entryId: entryId,
      grams: grams,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );
    return _dataSource.getById(entryId);
  }

  @override
  Future<void> deleteEntry(int entryId) => _dataSource.delete(entryId);
}
