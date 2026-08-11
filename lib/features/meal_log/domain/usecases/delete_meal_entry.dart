import '../repositories/meal_log_repository.dart';

class DeleteMealEntry {
  const DeleteMealEntry(this._repository);

  final MealLogRepository _repository;

  Future<void> call(int entryId) => _repository.deleteEntry(entryId);
}
