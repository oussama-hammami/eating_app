import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../nutrition/domain/entities/food.dart';
import '../../../nutrition/domain/entities/quantity.dart';
import '../../../nutrition/presentation/providers/food_search_provider.dart';
import '../../data/datasources/meal_log_local_data_source.dart';
import '../../data/repositories/meal_log_repository_impl.dart';
import '../../domain/entities/daily_totals.dart';
import '../../domain/entities/meal_entry.dart';
import '../../domain/repositories/meal_log_repository.dart';
import '../../domain/usecases/add_meal_entry.dart';
import '../../domain/usecases/delete_meal_entry.dart';
import '../../domain/usecases/update_meal_entry.dart';
import '../../domain/usecases/watch_today_entries.dart';

final mealLogRepositoryProvider = Provider<MealLogRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return MealLogRepositoryImpl(MealLogLocalDataSource(db));
});

final addMealEntryProvider = Provider<AddMealEntry>((ref) {
  return AddMealEntry(ref.watch(mealLogRepositoryProvider));
});

final updateMealEntryProvider = Provider<UpdateMealEntry>((ref) {
  return UpdateMealEntry(ref.watch(mealLogRepositoryProvider));
});

final deleteMealEntryProvider = Provider<DeleteMealEntry>((ref) {
  return DeleteMealEntry(ref.watch(mealLogRepositoryProvider));
});

final watchTodayEntriesProvider = Provider<WatchTodayEntries>((ref) {
  return WatchTodayEntries(ref.watch(mealLogRepositoryProvider));
});

/// Today's logged entries. All CRUD mutations go through this notifier so
/// the UI and [dailyTotalsProvider] always reflect the latest state
/// immediately after an add/edit/delete.
class TodayMealLogNotifier extends AsyncNotifier<List<MealEntry>> {
  @override
  Future<List<MealEntry>> build() {
    return ref.read(watchTodayEntriesProvider)(DateTime.now());
  }

  Future<void> addFood(Food food, Quantity quantity, String languageCode) async {
    final now = DateTime.now();
    final conversions = await ref.read(foodRepositoryProvider).getUnitConversions(food.id);
    final add = ref.read(addMealEntryProvider);
    final entry = await add(
      food: food,
      quantity: quantity,
      ingredientGramsPerUnit: conversions,
      logDate: todayLogDate(now),
      loggedAt: now,
      languageCode: languageCode,
    );
    final current = state.valueOrNull ?? const [];
    state = AsyncData([...current, entry]);
  }

  Future<void> editEntry(MealEntry entry, Food food, Quantity quantity) async {
    final conversions = await ref.read(foodRepositoryProvider).getUnitConversions(food.id);
    final update = ref.read(updateMealEntryProvider);
    final updated = await update(
      entry: entry,
      food: food,
      quantity: quantity,
      ingredientGramsPerUnit: conversions,
    );
    final current = state.valueOrNull ?? const [];
    state = AsyncData([
      for (final e in current) if (e.id == entry.id) updated else e,
    ]);
  }

  Future<void> removeEntry(int entryId) async {
    final delete = ref.read(deleteMealEntryProvider);
    await delete(entryId);
    final current = state.valueOrNull ?? const [];
    state = AsyncData([
      for (final e in current) if (e.id != entryId) e,
    ]);
  }
}

final todayMealLogProvider =
    AsyncNotifierProvider<TodayMealLogNotifier, List<MealEntry>>(
  TodayMealLogNotifier.new,
);

/// Pure derived total — recomputes instantly whenever the entries list
/// changes, no extra DB round-trip needed.
final dailyTotalsProvider = Provider<DailyTotals>((ref) {
  final entries = ref.watch(todayMealLogProvider).valueOrNull ?? const [];
  return DailyTotals.fromEntries(entries);
});
