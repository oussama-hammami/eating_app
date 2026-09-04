import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/local_storage.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/stat_chip.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/community_recipes_remote_data_source.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/recipe_filter.dart';
import '../widgets/recipe_filter_panel.dart';
import '../widgets/recipe_photo.dart';

/// Read-only browse screen for community-contributed recipes, fetched from
/// the `community_recipies` table on Supabase. Nutrition values come
/// straight from that curated source data — they are NOT recomputed via
/// food matching, since resolving a recipe's free-text ingredient names
/// against the food database produced inaccurate totals whenever a name
/// didn't confidently match.
class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key, required this.onAddToRecipes});

  /// Adds a copy of a community recipe into the user's own Recipes list.
  final void Function(Recipe recipe) onAddToRecipes;

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  final _storage = LocalStorage();

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
    try {
      final recipes = await fetchCommunityRecipes();
      unawaited(_storage.cacheCommunityRecipes(recipes));
      if (!mounted) return;
      setState(() {
        _recipes = recipes;
        _loading = false;
      });
    } catch (_) {
      // Network failures shouldn't surface raw exception text to users —
      // fall back to the last cache we have, or a friendly retry message.
      final cached = await _storage.loadCachedCommunityRecipes();
      if (!mounted) return;
      setState(() {
        _recipes = cached;
        _loading = false;
        _hasError = true;
        _showingCachedData = cached.isNotEmpty;
      });
    }
  }

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
                      child: ListTile(
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
                        title: Text(
                          recipe.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
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
                                icon: Icons.fitness_center,
                                label: l10n.proteinGChip(recipe.protein),
                                color: const Color(0xFF2A835F),
                              ),
                              StatChip(
                                icon: Icons.people_outline,
                                label: l10n.portionsChip(recipe.portions),
                                color: const Color(0xFF92003A),
                              ),
                            ],
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
