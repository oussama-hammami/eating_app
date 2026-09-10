import 'package:flutter/material.dart';

import '../features/groceries/domain/entities/grocery_item.dart';
import '../features/groceries/domain/usecases/scale_quantity.dart';
import '../features/groceries/presentation/screens/groceries_tab.dart';
import '../features/planner/domain/entities/meal_plan_entry.dart';
import '../features/planner/presentation/screens/planner_tab.dart';
import '../features/recipes/data/community_recipes_repository.dart';
import '../features/recipes/domain/entities/recipe.dart';
import '../features/recipes/presentation/screens/community_tab.dart';
import '../features/recipes/presentation/screens/recipes_tab.dart';
import '../l10n/app_localizations.dart';
import 'local_storage.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key, this.communityRecipesRepository});

  /// Overrides [CommunityTab]'s repository — overridable (e.g. in tests) so
  /// mounting the shell doesn't require a live Supabase setup. Null keeps
  /// [CommunityTab]'s own default (a real Supabase-backed repository).
  final CommunityRecipesRepository? communityRecipesRepository;

  @override
  State<RootShell> createState() => _RootShellState();
}

/// State is split into per-domain [ValueNotifier]s (recipes, groceries, meal
/// plan, ...) instead of one [setState] for the whole shell. Each tab is
/// wrapped in its own [AnimatedBuilder] listening only to the notifiers it
/// needs, so e.g. toggling a grocery item's checkbox notifies just the
/// Groceries tab's subtree instead of rebuilding (and re-running `build()`
/// on) all 4 [IndexedStack] tabs.
class _RootShellState extends State<RootShell> {
  final _storage = LocalStorage();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ValueNotifier<int> _tabIndex = ValueNotifier(0);
  final ValueNotifier<List<Recipe>> _recipes = ValueNotifier([]);
  final ValueNotifier<List<GroceryItem>> _groceries = ValueNotifier([]);
  final ValueNotifier<List<MealPlanEntry>> _mealPlan = ValueNotifier([]);

  /// Ids of the recipes whose ingredients contributed to the current
  /// grocery list — shown via the Groceries tab's "Recipes" button.
  final ValueNotifier<List<String>> _groceriesSourceRecipeIds = ValueNotifier([]);

  final ValueNotifier<int> _groceryResetSignal = ValueNotifier(0);

  /// Tab indexes visited at least once — a tab not in this set renders as an
  /// empty placeholder instead of its real widget, so e.g. the Community
  /// tab's network fetch doesn't fire in `initState` before the user has
  /// ever opened that tab. Once visited, a tab stays built (matching
  /// [IndexedStack]'s normal state-preservation) even after switching away.
  final Set<int> _visitedTabIndexes = {0};

  @override
  void initState() {
    super.initState();
    _loadPersistedState();
  }

  @override
  void dispose() {
    _tabIndex.dispose();
    _recipes.dispose();
    _groceries.dispose();
    _mealPlan.dispose();
    _groceriesSourceRecipeIds.dispose();
    _groceryResetSignal.dispose();
    super.dispose();
  }

  /// Awaits a [LocalStorage] save and swallows any error — persistence
  /// failures shouldn't crash the app since the in-memory state is already
  /// up to date.
  Future<void> _persist(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (_) {}
  }

  void _setTabIndex(int index) {
    _visitedTabIndexes.add(index);
    _tabIndex.value = index;
  }

  Future<void> _loadPersistedState() async {
    await _storage.ensureSchemaVersion();
    final recipes = await _storage.loadRecipes();
    final groceries = await _storage.loadGroceries();
    final mealPlan = await _storage.loadMealPlan();
    final groceriesSourceRecipeIds = await _storage.loadGroceriesSourceRecipeIds();
    if (!mounted) return;
    _recipes.value = [..._recipes.value, ...recipes];
    _groceries.value = [..._groceries.value, ...groceries];
    _mealPlan.value = [..._mealPlan.value, ...mealPlan];
    _groceriesSourceRecipeIds.value = [
      ..._groceriesSourceRecipeIds.value,
      ...groceriesSourceRecipeIds,
    ];
  }

  void _addRecipe(Recipe recipe) {
    _recipes.value = [..._recipes.value, recipe];
    _persist(() => _storage.saveRecipes(_recipes.value));
  }

  void _updateRecipe(int index, Recipe recipe) {
    _recipes.value = List.of(_recipes.value)..[index] = recipe;
    _persist(() => _storage.saveRecipes(_recipes.value));
  }

  void _deleteRecipe(int index) {
    _recipes.value = List.of(_recipes.value)..removeAt(index);
    _persist(() => _storage.saveRecipes(_recipes.value));
  }

  void _resetGroceries() {
    _groceries.value = [];
    _groceriesSourceRecipeIds.value = [];
    _groceryResetSignal.value++;
    _persist(() => _storage.saveGroceries(_groceries.value));
    _persist(() => _storage.saveGroceriesSourceRecipeIds(_groceriesSourceRecipeIds.value));
  }

  /// Adds [recipeIds] to the set of recipes credited with the current
  /// grocery list (order-preserving, no duplicates).
  void _addGroceriesSourceRecipeIds(Iterable<String> recipeIds) {
    final updated = List.of(_groceriesSourceRecipeIds.value);
    for (final id in recipeIds) {
      if (!updated.contains(id)) updated.add(id);
    }
    _groceriesSourceRecipeIds.value = updated;
    _persist(() => _storage.saveGroceriesSourceRecipeIds(_groceriesSourceRecipeIds.value));
  }

  /// Merges (name, quantity) pairs into the groceries list, combining
  /// quantities for ingredients that already appear (matched
  /// case-insensitively by name) — shared by "Add to groceries" and the
  /// planner's "Generate groceries".
  void _mergeIntoGroceries(Iterable<MapEntry<String, String>> ingredients) {
    final rawQuantitiesByKey = <String, List<String>>{};
    final displayNameByKey = <String, String>{};
    final order = <String>[];

    for (final item in _groceries.value) {
      final key = item.name.trim().toLowerCase();
      order.add(key);
      displayNameByKey[key] = item.name;
      rawQuantitiesByKey[key] = List.of(item.rawQuantities);
    }

    for (final ingredient in ingredients) {
      final key = ingredient.key.trim().toLowerCase();
      if (key.isEmpty) continue;
      if (!order.contains(key)) order.add(key);
      displayNameByKey[key] = ingredient.key.trim();
      rawQuantitiesByKey.putIfAbsent(key, () => []).add(ingredient.value.trim());
    }

    final existingCheckedByKey = {
      for (final item in _groceries.value) item.name.trim().toLowerCase(): item.checked,
    };

    _groceries.value = order.map((key) {
      return GroceryItem(
        name: displayNameByKey[key]!,
        rawQuantities: rawQuantitiesByKey[key]!,
        checked: existingCheckedByKey[key] ?? false,
      );
    }).toList();
    _setTabIndex(2);
    _persist(() => _storage.saveGroceries(_groceries.value));
  }

  void _addGroceryItem(String name, String quantity) {
    _mergeIntoGroceries([MapEntry(name, quantity)]);
  }

  void _addToGroceries(List<Recipe> selectedRecipes) {
    _mergeIntoGroceries(
      selectedRecipes.expand(
        (recipe) => recipe.ingredients.map((i) => MapEntry(i.name, i.quantity)),
      ),
    );
    _addGroceriesSourceRecipeIds(selectedRecipes.map((r) => r.id));
  }

  void _generateGroceries(List<Recipe> selectedRecipes) {
    final rawQuantitiesByKey = <String, List<String>>{};
    final displayNameByKey = <String, String>{};
    final order = <String>[];

    for (final recipe in selectedRecipes) {
      for (final ingredient in recipe.ingredients) {
        final key = ingredient.name.trim().toLowerCase();
        if (key.isEmpty) continue;
        if (!order.contains(key)) order.add(key);
        displayNameByKey[key] = ingredient.name.trim();
        rawQuantitiesByKey.putIfAbsent(key, () => []).add(ingredient.quantity.trim());
      }
    }

    _groceries.value = order.map((key) {
      return GroceryItem(
        name: displayNameByKey[key]!,
        rawQuantities: rawQuantitiesByKey[key]!,
      );
    }).toList();
    _groceriesSourceRecipeIds.value = selectedRecipes.map((r) => r.id).toList();
    _setTabIndex(2);
    _persist(() => _storage.saveGroceries(_groceries.value));
    _persist(() => _storage.saveGroceriesSourceRecipeIds(_groceriesSourceRecipeIds.value));
  }

  Recipe? _findRecipe(String recipeId) {
    for (final recipe in _recipes.value) {
      if (recipe.id == recipeId) return recipe;
    }
    return null;
  }

  void _addMealPlanEntry(MealPlanEntry entry) {
    _mealPlan.value = [..._mealPlan.value, entry];
    _persist(() => _storage.saveMealPlan(_mealPlan.value));
  }

  void _removeMealPlanEntry(String entryId) {
    _mealPlan.value = _mealPlan.value.where((e) => e.id != entryId).toList();
    _persist(() => _storage.saveMealPlan(_mealPlan.value));
  }

  /// Merges import from a scanned meal plan: adds any recipes the receiving
  /// device doesn't already have (matched by id), then adds the entries —
  /// skipping ones for a day+meal+recipe already present, so re-importing
  /// the same week is a no-op.
  void _importMealPlan(List<MealPlanEntry> entries, List<Recipe> recipes) {
    final updatedRecipes = List.of(_recipes.value);
    for (final recipe in recipes) {
      if (_findRecipe(recipe.id) == null) {
        updatedRecipes.add(recipe);
      }
    }
    final updatedMealPlan = List.of(_mealPlan.value);
    for (final entry in entries) {
      final alreadyPlanned = updatedMealPlan.any(
        (e) => e.date == entry.date && e.mealType == entry.mealType && e.recipeId == entry.recipeId,
      );
      if (!alreadyPlanned) {
        updatedMealPlan.add(entry);
      }
    }
    _recipes.value = updatedRecipes;
    _mealPlan.value = updatedMealPlan;
    _persist(() => _storage.saveRecipes(_recipes.value));
    _persist(() => _storage.saveMealPlan(_mealPlan.value));
  }

  void _generateGroceriesFromMealPlan(List<MealPlanEntry> weekEntries) {
    final ingredients = <MapEntry<String, String>>[];
    final recipeIds = <String>{};
    for (final entry in weekEntries) {
      final recipe = _findRecipe(entry.recipeId);
      if (recipe == null || recipe.portions <= 0) continue;
      recipeIds.add(recipe.id);
      final factor = entry.servings / recipe.portions;
      for (final ingredient in recipe.ingredients) {
        ingredients.add(MapEntry(ingredient.name, scaleQuantity(ingredient.quantity, factor)));
      }
    }
    _mergeIntoGroceries(ingredients);
    _addGroceriesSourceRecipeIds(recipeIds);
  }

  void _onGroceriesChanged() {
    // The Groceries tab mutates its items in place (e.g. toggling a
    // checkbox), so re-assign to notify listeners of that tab alone.
    _groceries.value = List.of(_groceries.value);
    _persist(() => _storage.saveGroceries(_groceries.value));
  }

  Widget _recipesTab() {
    return AnimatedBuilder(
      animation: Listenable.merge([_recipes, _groceryResetSignal]),
      builder: (context, _) => RecipesTab(
        recipes: _recipes.value,
        onAddRecipe: _addRecipe,
        onUpdateRecipe: _updateRecipe,
        onDeleteRecipe: _deleteRecipe,
        onAddToGroceries: _addToGroceries,
        onGenerateGroceries: _generateGroceries,
        groceryResetSignal: _groceryResetSignal.value,
      ),
    );
  }

  Widget _plannerTab() {
    return AnimatedBuilder(
      animation: Listenable.merge([_recipes, _mealPlan]),
      builder: (context, _) => PlannerTab(
        recipes: _recipes.value,
        entries: _mealPlan.value,
        onAddEntry: _addMealPlanEntry,
        onRemoveEntry: _removeMealPlanEntry,
        onAddRecipe: _addRecipe,
        onImportMealPlan: _importMealPlan,
        onGenerateGroceries: _generateGroceriesFromMealPlan,
      ),
    );
  }

  Widget _groceriesTab() {
    return AnimatedBuilder(
      animation: Listenable.merge([_groceries, _groceriesSourceRecipeIds, _recipes]),
      builder: (context, _) => GroceriesTab(
        items: _groceries.value,
        onChanged: _onGroceriesChanged,
        onReset: _resetGroceries,
        onAddItem: _addGroceryItem,
        sourceRecipes: _groceriesSourceRecipeIds.value
            .map(_findRecipe)
            .whereType<Recipe>()
            .toList(),
      ),
    );
  }

  Widget _communityTab() {
    return CommunityTab(
      onAddToRecipes: _addRecipe,
      repository: widget.communityRecipesRepository,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(l10n.appTitle, style: Theme.of(context).textTheme.titleLarge),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, size: 16, color: colorScheme.secondary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.privacyLocalStorageBadge,
                      style: TextStyle(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          ValueListenableBuilder<int>(
            valueListenable: _tabIndex,
            builder: (context, tabIndex, _) {
              return IndexedStack(
                index: tabIndex,
                children: [
                  _visitedTabIndexes.contains(0) ? _recipesTab() : const SizedBox.shrink(),
                  _visitedTabIndexes.contains(1) ? _plannerTab() : const SizedBox.shrink(),
                  _visitedTabIndexes.contains(2) ? _groceriesTab() : const SizedBox.shrink(),
                  _visitedTabIndexes.contains(3) ? _communityTab() : const SizedBox.shrink(),
                ],
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 4, top: 4),
              child: IconButton(
                icon: const Icon(Icons.menu),
                tooltip: AppLocalizations.of(context)!.menuTooltip,
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _tabIndex,
        builder: (context, tabIndex, _) => NavigationBar(
          selectedIndex: tabIndex,
          onDestinationSelected: _setTabIndex,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.restaurant_menu),
              label: AppLocalizations.of(context)!.navRecipes,
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              label: AppLocalizations.of(context)!.navPlanner,
            ),
            NavigationDestination(
              icon: const Icon(Icons.shopping_cart),
              label: AppLocalizations.of(context)!.navGroceries,
            ),
            NavigationDestination(
              icon: const Icon(Icons.groups_outlined),
              label: AppLocalizations.of(context)!.navCommunity,
            ),
          ],
        ),
      ),
    );
  }
}
