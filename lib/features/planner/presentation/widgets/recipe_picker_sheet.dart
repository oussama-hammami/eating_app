import 'package:flutter/material.dart';

import '../../../../core/widgets/stat_chip.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../recipes/data/community_recipes_remote_data_source.dart';
import '../../../recipes/domain/entities/meal_type.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../../recipes/domain/entities/recipe_filter.dart';
import '../../../recipes/presentation/widgets/recipe_filter_panel.dart';

/// Full-screen recipe picker for the planner's "Add meal" flow — "My
/// recipes" plus a lazily-fetched "Community" section. Pops with the chosen
/// [Recipe], or null if cancelled.
class RecipePickerSheet extends StatefulWidget {
  const RecipePickerSheet({super.key, required this.myRecipes, required this.mealType});

  final List<Recipe> myRecipes;

  /// Slot being filled (e.g. breakfast, snack) — seeds the filter panel so
  /// the picker starts scoped to it.
  final MealType mealType;

  @override
  State<RecipePickerSheet> createState() => _RecipePickerSheetState();
}

class _RecipePickerSheetState extends State<RecipePickerSheet> {
  late final Future<List<Recipe>> _communityFuture = fetchCommunityRecipes();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late RecipeFilter _filter = RecipeFilter(mealTypes: {widget.mealType});
  bool _filtersExpanded = false;

  int _activeFilterCount() {
    var count = 0;
    if (_filter.calories.isActive) count++;
    if (_filter.protein.isActive) count++;
    if (_filter.carbs.isActive) count++;
    if (_filter.fat.isActive) count++;
    if (_filter.mealTypes.isNotEmpty) count++;
    if (_filter.includeIngredients.isNotEmpty) count++;
    if (_filter.excludeIngredients.isNotEmpty) count++;
    return count;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Recipe> _filtered(List<Recipe> recipes) {
    final query = _searchQuery.trim().toLowerCase();
    return recipes
        .where(
          (r) =>
              (query.isEmpty || r.name.toLowerCase().contains(query)) &&
              recipeMatchesFilter(r, _filter),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    Widget recipeTile(Recipe recipe) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: 8,
                children: [
                  StatChip(
                    icon: recipe.mealType.icon,
                    label: recipe.mealType.label(l10n),
                    color: colorScheme.primary,
                  ),
                  StatChip(
                    icon: Icons.local_fire_department,
                    label: l10n.caloriesKcalChip(recipe.calories),
                    color: colorScheme.secondary,
                  ),
                  StatChip(
                    icon: Icons.people_outline,
                    label: l10n.portionsChip(recipe.portions),
                    color: const Color(0xFF92003A),
                  ),
                ],
              ),
            ),
            onTap: () => Navigator.of(context).pop(recipe),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.plannerPickRecipeTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: l10n.searchRecipesHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                }),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(
                      _filter.isActive
                          ? l10n.filtersActiveButton(_activeFilterCount())
                          : l10n.filtersButton,
                    ),
                    avatar: const Icon(Icons.filter_alt_outlined, size: 18),
                    selected: _filtersExpanded,
                    onSelected: (value) => setState(() => _filtersExpanded = value),
                  ),
                ],
              ),
            ),
            if (_filtersExpanded)
              RecipeFilterPanel(
                filter: _filter,
                onApply: (updated) => setState(() => _filter = updated),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Text(
                    l10n.plannerMyRecipesSection,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  Builder(builder: (context) {
                    final filtered = _filtered(widget.myRecipes);
                    if (widget.myRecipes.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(l10n.recipesEmpty, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                      );
                    }
                    if (filtered.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(l10n.recipesSearchEmpty, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                      );
                    }
                    return Column(children: filtered.map(recipeTile).toList());
                  }),
                  const SizedBox(height: 20),
                  Text(
                    l10n.plannerCommunitySection,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  FutureBuilder<List<Recipe>>(
                    future: _communityFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            l10n.plannerCommunityUnavailable,
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        );
                      }
                      final filtered = _filtered(snapshot.data!);
                      if (filtered.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(l10n.recipesSearchEmpty, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        );
                      }
                      return Column(children: filtered.map(recipeTile).toList());
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
