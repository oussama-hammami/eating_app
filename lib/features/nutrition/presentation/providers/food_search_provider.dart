import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/datasources/food_local_data_source.dart';
import '../../data/repositories/food_repository_impl.dart';
import '../../domain/entities/food.dart';
import '../../domain/repositories/food_repository.dart';
import '../../domain/usecases/search_foods.dart';

const searchDebounce = Duration(milliseconds: 200);
const maxSuggestions = 5;

final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return FoodRepositoryImpl(FoodLocalDataSource(db));
});

final searchFoodsProvider = Provider<SearchFoods>((ref) {
  return SearchFoods(ref.watch(foodRepositoryProvider));
});

/// Holds the debounced, in-flight-safe list of food suggestions for the
/// current search query text.
class FoodSearchNotifier extends AsyncNotifier<List<Food>> {
  Timer? _debounceTimer;
  int _requestId = 0;

  @override
  Future<List<Food>> build() async {
    ref.onDispose(() => _debounceTimer?.cancel());
    return const [];
  }

  void onQueryChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      state = const AsyncData([]);
      return;
    }

    _debounceTimer = Timer(searchDebounce, () => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    final requestId = ++_requestId;
    state = const AsyncLoading<List<Food>>().copyWithPrevious(state);

    final searchFoods = ref.read(searchFoodsProvider);
    try {
      final results = await searchFoods(query, limit: maxSuggestions);
      if (requestId != _requestId) return; // a newer query superseded this one
      state = AsyncData(results);
    } catch (error, stackTrace) {
      if (requestId != _requestId) return;
      state = AsyncError(error, stackTrace);
    }
  }

  void clear() {
    _debounceTimer?.cancel();
    state = const AsyncData([]);
  }
}

final foodSearchProvider =
    AsyncNotifierProvider<FoodSearchNotifier, List<Food>>(
  FoodSearchNotifier.new,
);
