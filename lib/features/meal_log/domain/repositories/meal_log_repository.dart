import '../entities/meal_entry.dart';

abstract class MealLogRepository {
  Future<List<MealEntry>> getEntriesForDate(String logDate);

  /// Persists a new entry; macros are precomputed by the caller (see
  /// [MacroCalculator]) so the repository stays pure CRUD.
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
  });

  Future<MealEntry> updateEntry({
    required int entryId,
    required double grams,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
  });

  Future<void> deleteEntry(int entryId);
}
