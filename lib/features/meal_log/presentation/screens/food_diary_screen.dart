import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
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
    final languageCode = Localizations.localeOf(context).languageCode;
    final conversions = await ref.read(foodRepositoryProvider).getUnitConversions(food.id);
    if (!mounted) return;
    final quantity = await showQuantityDialog(
      context,
      foodName: food.displayName(languageCode),
      ingredientUnits: conversions.keys.toSet(),
    );
    if (quantity == null) return;

    await ref.read(todayMealLogProvider.notifier).addFood(food, quantity, languageCode);

    _searchController.clear();
    ref.read(foodSearchProvider.notifier).clear();
  }

  Future<void> _onEditEntry(MealEntry entry) async {
    final conversions = await ref.read(foodRepositoryProvider).getUnitConversions(entry.foodId);
    if (!mounted) return;
    final quantity = await showQuantityDialog(
      context,
      foodName: entry.foodName,
      ingredientUnits: conversions.keys.toSet(),
      initialQuantity: entry.quantity,
    );
    if (quantity == null) return;

    final food = await ref.read(foodRepositoryProvider).getById(entry.foodId);
    if (food == null || !mounted) return;

    await ref.read(todayMealLogProvider.notifier).editEntry(entry, food, quantity);
  }

  Future<void> _onDeleteEntry(int entryId) {
    return ref.read(todayMealLogProvider.notifier).removeEntry(entryId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final searchState = ref.watch(foodSearchProvider);
    final todayState = ref.watch(todayMealLogProvider);
    final totals = ref.watch(dailyTotalsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.foodDiaryTitle)),
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
              child: Text(l10n.searchErrorLabel(error.toString())),
            ),
          ),
          const Divider(height: 24),
          Expanded(
            child: todayState.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return Center(child: Text(l10n.noFoodsLoggedToday));
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
              error: (error, _) => Center(child: Text(l10n.errorLabel(error.toString()))),
            ),
          ),
        ],
      ),
    );
  }
}
