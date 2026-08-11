import '../entities/meal_entry.dart';
import '../repositories/meal_log_repository.dart';

/// Returns the log-date key ("YYYY-MM-DD") for "today" in local time.
String todayLogDate(DateTime now) {
  final y = now.year.toString().padLeft(4, '0');
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

class WatchTodayEntries {
  const WatchTodayEntries(this._repository);

  final MealLogRepository _repository;

  Future<List<MealEntry>> call(DateTime now) =>
      _repository.getEntriesForDate(todayLogDate(now));
}
