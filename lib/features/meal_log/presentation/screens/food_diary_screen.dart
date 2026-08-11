import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nutrition/domain/entities/food.dart';
import '../../../nutrition/presentation/providers/food_search_provider.dart';
import '../../../nutrition/presentation/widgets/food_search_field.dart';
import '../../../nutrition/presentation/widgets/food_suggestion_tile.dart';
import '../../domain/entities/meal_entry.dart';
import '../providers/meal_log_provider.dart';
import '../widgets/daily_totals_card.dart';
import '../widgets/meal_entry_tile.dart';
import '../widgets/quantity_dialog.dart';

class FoodDiaryScreen extends ConsumerStatefulWidget {
  const FoodDiaryScreen({super.key});

  @override
  ConsumerState<FoodDiaryScreen> createState() => _FoodDiaryScreenState();
}

class _FoodDiaryScreenState extends ConsumerState<FoodDiaryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onFoodSelected(Food food) async {
    final grams = await showQuantityDialog(context, foodName: food.foodName);
    if (grams == null) return;

    await ref.read(todayMealLogProvider.notifier).addFood(food, grams);

    _searchController.clear();
    ref.read(foodSearchProvider.notifier).clear();
  }

  Future<void> _onEditEntry(MealEntry entry) async {
    final grams = await showQuantityDialog(
      context,
      foodName: entry.foodName,
      initialGrams: entry.grams,
    );
    if (grams == null) return;

    final food = await ref.read(foodRepositoryProvider).getById(entry.foodId);
    if (food == null || !mounted) return;

    await ref.read(todayMealLogProvider.notifier).editEntry(entry, food, grams);
  }

  Future<void> _onDeleteEntry(int entryId) {
    return ref.read(todayMealLogProvider.notifier).removeEntry(entryId);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(foodSearchProvider);
    final todayState = ref.watch(todayMealLogProvider);
    final totals = ref.watch(dailyTotalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Food Diary')),
      body: Column(
        children: [
          DailyTotalsCard(totals: totals),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FoodSearchField(controller: _searchController),
          ),
          searchState.when(
            data: (suggestions) {
              if (suggestions.isEmpty) return const SizedBox.shrink();
              return Card(
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final food = suggestions[index];
                    return FoodSuggestionTile(
                      food: food,
                      onTap: () => _onFoodSelected(food),
                    );
                  },
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(12),
              child: LinearProgressIndicator(),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Search error: $error'),
            ),
          ),
          const Divider(height: 24),
          Expanded(
            child: todayState.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return const Center(child: Text('No foods logged yet today.'));
                }
                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return MealEntryTile(
                      entry: entry,
                      onEdit: () => _onEditEntry(entry),
                      onDelete: () => _onDeleteEntry(entry.id),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
