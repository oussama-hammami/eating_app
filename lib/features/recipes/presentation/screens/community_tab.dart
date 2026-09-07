import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/stat_chip.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/community_recipes_repository.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/recipe_filter.dart';
import '../widgets/recipe_list_tile.dart';
import '../widgets/recipe_photo.dart';
import '../widgets/recipe_search_and_filter_bar.dart';

/// Read-only browse screen for community-contributed recipes, fetched from
/// the `community_recipies` table on Supabase. Nutrition values come
/// straight from that curated source data — they are NOT recomputed via
/// food matching, since resolving a recipe's free-text ingredient names
/// against the food database produced inaccurate totals whenever a name
/// didn't confidently match.
class CommunityTab extends StatefulWidget {
  const CommunityTab({
    super.key,
    required this.onAddToRecipes,
    this.repository,
  });

  /// Adds a copy of a community recipe into the user's own Recipes list.
  final void Function(Recipe recipe) onAddToRecipes;

  /// Defaults to a real Supabase-backed [CommunityRecipesRepository] —
  /// overridable (e.g. in tests) so this screen doesn't need a live
  /// network/Supabase setup just to be mounted.
  final CommunityRecipesRepository? repository;

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  late final _repository = widget.repository ?? CommunityRecipesRepository();

  List<Recipe> _recipes = [];
  bool _loading = true;
  // True once a fetch has failed and the list below is stale cached data
  // rather than a fresh one, or empty because there's no cache either.
  bool _showingCachedData = false;
  bool _hasError = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  RecipeFilter _filter = const RecipeFilter();
  bool _filtersExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _loading = true;
      _hasError = false;
      _showingCachedData = false;
    });
    final result = await _repository.fetch();
    if (!mounted) return;
    setState(() {
      _recipes = result.recipes;
      _loading = false;
      _hasError = result.hasError;
      _showingCachedData = result.isFromCache;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToMyRecipes(Recipe recipe) {
    widget.onAddToRecipes(recipe.copy());
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.addedToRecipes(recipe.name))),
    );
  }

  void _openRecipeDetailsDialog(Recipe recipe) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(recipe.name),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: RecipePhoto(
                          path: recipe.photoPath,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StatChip(
                        icon: recipe.mealType.icon,
                        label: recipe.mealType.label(l10n),
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.recipeStatsLine(recipe.calories, recipe.protein, recipe.portions),
                      ),
                      const SizedBox(height: 16),
                      if (recipe.ingredients.isNotEmpty) ...[
                        Text(
                          l10n.ingredients,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...recipe.ingredients.asMap().entries.map((entry) {
                          final i = entry.key;
                          final ingredient = entry.value;
                          return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                ingredient.quantity.isEmpty
                                    ? ingredient.name
                                    : '${ingredient.name} — ${ingredient.quantity}',
                              ),
                              value: recipe.checkedIngredients[i],
                              onChanged: (checked) {
                                setDialogState(() {
                                  recipe.checkedIngredients[i] = checked ?? false;
                                });
                              },
                            );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.close),
                ),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _addToMyRecipes(recipe);
                  },
                  icon: const Icon(Icons.playlist_add),
                  label: Text(l10n.addToRecipes),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final recipes = _recipes;
    final query = _searchQuery.trim().toLowerCase();
    final filtered = recipes
        .where(
          (r) =>
              (query.isEmpty || r.name.toLowerCase().contains(query)) &&
              recipeMatchesFilter(r, _filter),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.communityTitle)),
      body: Column(
        children: [
          if (recipes.isNotEmpty)
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
          if (_showingCachedData)
            MaterialBanner(
              content: Text(l10n.communityOfflineCached),
              leading: const Icon(Icons.cloud_off),
              actions: [
                TextButton(onPressed: _loadRecipes, child: Text(l10n.retry)),
              ],
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _hasError && recipes.isEmpty
                ? EmptyState(
                    icon: Icons.cloud_off,
                    message: l10n.communityLoadError,
                    actionLabel: l10n.retry,
                    onAction: _loadRecipes,
                  )
                : recipes.isEmpty
                ? EmptyState(icon: Icons.groups_outlined, message: l10n.communityEmpty)
                : filtered.isEmpty
                    ? EmptyState(icon: Icons.search_off, message: l10n.recipesSearchEmpty)
                    : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final recipe = filtered[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: RecipeListTile(
                        recipe: recipe,
                        leading: recipe.photoPath == null
                            ? null
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: RecipePhoto(
                                  path: recipe.photoPath!,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              ),
                        trailing: IconButton(
                          icon: const Icon(Icons.playlist_add),
                          color: colorScheme.primary,
                          tooltip: l10n.addToRecipes,
                          onPressed: () => _addToMyRecipes(recipe),
                        ),
                        onTap: () => _openRecipeDetailsDialog(recipe),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
