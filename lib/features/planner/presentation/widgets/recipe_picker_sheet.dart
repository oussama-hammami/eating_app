import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../recipes/data/community_recipes_repository.dart';
import '../../../recipes/domain/entities/meal_type.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../../recipes/domain/entities/recipe_filter.dart';
import '../../../recipes/presentation/widgets/recipe_list_tile.dart';
import '../../../recipes/presentation/widgets/recipe_search_and_filter_bar.dart';

/// Full-screen recipe picker for the planner's "Add meal" flow — "My
/// recipes" plus a lazily-fetched "Community" section. Pops with the chosen
/// [Recipe], or null if cancelled.
class RecipePickerSheet extends StatefulWidget {
  const RecipePickerSheet({
    super.key,
    required this.myRecipes,
    required this.mealType,
    this.communityRecipesRepository,
  });

  final List<Recipe> myRecipes;

  /// Slot being filled (e.g. breakfast, snack) — seeds the filter panel so
  /// the picker starts scoped to it.
  final MealType mealType;

  /// Defaults to a real Supabase-backed [CommunityRecipesRepository] —
  /// overridable (e.g. in tests) so this screen doesn't need a live
  /// network/Supabase setup just to be mounted.
  final CommunityRecipesRepository? communityRecipesRepository;

  @override
  State<RecipePickerSheet> createState() => _RecipePickerSheetState();
}

class _RecipePickerSheetState extends State<RecipePickerSheet> {
  late final _repository = widget.communityRecipesRepository ?? CommunityRecipesRepository();
  late final Future<CommunityRecipesResult> _communityFuture = _repository.fetch();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late RecipeFilter _filter = RecipeFilter(mealTypes: {widget.mealType});
  bool _filtersExpanded = false;

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
          child: RecipeListTile(
            recipe: recipe,
            showProtein: false,
            onTap: () => Navigator.of(context).pop(recipe),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.plannerPickRecipeTitle)),
      body: SafeArea(
        child: Column(
          children: [
            RecipeSearchAndFilterBar(
              searchController: _searchController,
              searchQuery: _searchQuery,
              onSearchChanged: (value) => setState(() => _searchQuery = value),
              onSearchCleared: () => setState(() {
                _searchController.clear();
                _searchQuery = '';
              }),
              filter: _filter,
              filtersExpanded: _filtersExpanded,
              onFiltersExpandedChanged: (value) => setState(() => _filtersExpanded = value),
              onFilterApply: (updated) => setState(() => _filter = updated),
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
                  FutureBuilder<CommunityRecipesResult>(
                    future: _communityFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final result = snapshot.data;
                      if (result == null || result.recipes.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            l10n.plannerCommunityUnavailable,
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        );
                      }
                      final filtered = _filtered(result.recipes);
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
