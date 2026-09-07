import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/recipe_filter.dart';
import 'recipe_filter_panel.dart';

/// Search field + filter toggle, with the [RecipeFilterPanel] expanding
/// below it when active. Shared by every screen that lists recipes
/// (Recipes tab, Community tab, the planner's recipe picker) so the search
/// UI and active-filter-count logic live in one place.
class RecipeSearchAndFilterBar extends StatelessWidget {
  const RecipeSearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onSearchCleared,
    required this.filter,
    required this.filtersExpanded,
    required this.onFiltersExpandedChanged,
    required this.onFilterApply,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchCleared;
  final RecipeFilter filter;
  final bool filtersExpanded;
  final ValueChanged<bool> onFiltersExpandedChanged;
  final ValueChanged<RecipeFilter> onFilterApply;

  int _activeFilterCount() {
    var count = 0;
    if (filter.calories.isActive) count++;
    if (filter.protein.isActive) count++;
    if (filter.carbs.isActive) count++;
    if (filter.fat.isActive) count++;
    if (filter.mealTypes.isNotEmpty) count++;
    if (filter.includeIngredients.isNotEmpty) count++;
    if (filter.excludeIngredients.isNotEmpty) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: l10n.searchRecipesHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: onSearchCleared,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text(
                  filter.isActive
                      ? l10n.filtersActiveButton(_activeFilterCount())
                      : l10n.filtersButton,
                ),
                avatar: const Icon(Icons.filter_alt_outlined, size: 18),
                selected: filtersExpanded,
                onSelected: onFiltersExpandedChanged,
              ),
            ],
          ),
        ),
        if (filtersExpanded)
          RecipeFilterPanel(filter: filter, onApply: onFilterApply),
      ],
    );
  }
}
