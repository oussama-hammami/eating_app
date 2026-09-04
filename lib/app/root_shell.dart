import 'package:flutter/material.dart';

import '../features/groceries/domain/entities/grocery_item.dart';
import '../features/groceries/domain/usecases/scale_quantity.dart';
import '../features/groceries/presentation/screens/groceries_tab.dart';
import '../features/planner/domain/entities/meal_plan_entry.dart';
import '../features/planner/presentation/screens/planner_tab.dart';
import '../features/recipes/domain/entities/recipe.dart';
import '../features/recipes/presentation/screens/community_tab.dart';
import '../features/recipes/presentation/screens/recipes_tab.dart';
import '../l10n/app_localizations.dart';
import 'local_storage.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  final _storage = LocalStorage();

  int _tabIndex = 0;
  final List<Recipe> _recipes = [];
  final List<GroceryItem> _groceries = [];
  final List<MealPlanEntry> _mealPlan = [];

  /// Ids of the recipes whose ingredients contributed to the current
  /// grocery list — shown via the Groceries tab's "Recipes" button.
  final List<String> _groceriesSourceRecipeIds = [];

  int _groceryResetSignal = 0;

  @override
  void initState() {
    super.initState();
    _loadPersistedState();
  }

  Future<void> _loadPersistedState() async {
    final recipes = await _storage.loadRecipes();
    final groceries = await _storage.loadGroceries();
    final mealPlan = await _storage.loadMealPlan();
    final groceriesSourceRecipeIds = await _storage.loadGroceriesSourceRecipeIds();
    if (!mounted) return;
    setState(() {
      _recipes.addAll(recipes);
      _groceries.addAll(groceries);
      _mealPlan.addAll(mealPlan);
      _groceriesSourceRecipeIds.addAll(groceriesSourceRecipeIds);
    });
  }

  void _addRecipe(Recipe recipe) {
    setState(() {
      _recipes.add(recipe);
    });
    _storage.saveRecipes(_recipes);
  }

  void _updateRecipe(int index, Recipe recipe) {
    setState(() {
      _recipes[index] = recipe;
    });
    _storage.saveRecipes(_recipes);
  }

  void _deleteRecipe(int index) {
    setState(() {
      _recipes.removeAt(index);
    });
    _storage.saveRecipes(_recipes);
  }

  void _resetGroceries() {
    setState(() {
      _groceries.clear();
      _groceriesSourceRecipeIds.clear();
      _groceryResetSignal++;
    });
    _storage.saveGroceries(_groceries);
    _storage.saveGroceriesSourceRecipeIds(_groceriesSourceRecipeIds);
  }

  /// Adds [recipeIds] to the set of recipes credited with the current
  /// grocery list (order-preserving, no duplicates).
  void _addGroceriesSourceRecipeIds(Iterable<String> recipeIds) {
    setState(() {
      for (final id in recipeIds) {
        if (!_groceriesSourceRecipeIds.contains(id)) {
          _groceriesSourceRecipeIds.add(id);
        }
      }
    });
    _storage.saveGroceriesSourceRecipeIds(_groceriesSourceRecipeIds);
  }

  /// Merges (name, quantity) pairs into `_groceries`, combining quantities
  /// for ingredients that already appear (matched case-insensitively by
  /// name) — shared by "Add to groceries" and the planner's
  /// "Generate groceries".
  void _mergeIntoGroceries(Iterable<MapEntry<String, String>> ingredients) {
    final rawQuantitiesByKey = <String, List<String>>{};
    final displayNameByKey = <String, String>{};
    final order = <String>[];

    for (final item in _groceries) {
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
      for (final item in _groceries) item.name.trim().toLowerCase(): item.checked,
    };

    setState(() {
      _groceries
        ..clear()
        ..addAll(order.map((key) {
          return GroceryItem(
            name: displayNameByKey[key]!,
            rawQuantities: rawQuantitiesByKey[key]!,
            checked: existingCheckedByKey[key] ?? false,
          );
        }));
      _tabIndex = 2;
    });
    _storage.saveGroceries(_groceries);
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

    setState(() {
      _groceries
        ..clear()
        ..addAll(order.map((key) {
          return GroceryItem(
            name: displayNameByKey[key]!,
            rawQuantities: rawQuantitiesByKey[key]!,
          );
        }));
      _groceriesSourceRecipeIds
        ..clear()
        ..addAll(selectedRecipes.map((r) => r.id));
      _tabIndex = 2;
    });
    _storage.saveGroceries(_groceries);
    _storage.saveGroceriesSourceRecipeIds(_groceriesSourceRecipeIds);
  }

  Recipe? _findRecipe(String recipeId) {
    for (final recipe in _recipes) {
      if (recipe.id == recipeId) return recipe;
    }
    return null;
  }

  void _addMealPlanEntry(MealPlanEntry entry) {
    setState(() {
      _mealPlan.add(entry);
    });
    _storage.saveMealPlan(_mealPlan);
  }

  void _removeMealPlanEntry(String entryId) {
    setState(() {
      _mealPlan.removeWhere((e) => e.id == entryId);
    });
    _storage.saveMealPlan(_mealPlan);
  }

  /// Merges import from a scanned meal plan: adds any recipes the receiving
  /// device doesn't already have (matched by id), then adds the entries —
  /// skipping ones for a day+meal+recipe already present, so re-importing
  /// the same week is a no-op.
  void _importMealPlan(List<MealPlanEntry> entries, List<Recipe> recipes) {
    setState(() {
      for (final recipe in recipes) {
        if (_findRecipe(recipe.id) == null) {
          _recipes.add(recipe);
        }
      }
      for (final entry in entries) {
        final alreadyPlanned = _mealPlan.any(
          (e) => e.date == entry.date && e.mealType == entry.mealType && e.recipeId == entry.recipeId,
        );
        if (!alreadyPlanned) {
          _mealPlan.add(entry);
        }
      }
    });
    _storage.saveRecipes(_recipes);
    _storage.saveMealPlan(_mealPlan);
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

  List<Recipe> get _groceriesSourceRecipes => _groceriesSourceRecipeIds
      .map(_findRecipe)
      .whereType<Recipe>()
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: [
          RecipesTab(
            recipes: _recipes,
            onAddRecipe: _addRecipe,
            onUpdateRecipe: _updateRecipe,
            onDeleteRecipe: _deleteRecipe,
            onAddToGroceries: _addToGroceries,
            onGenerateGroceries: _generateGroceries,
            groceryResetSignal: _groceryResetSignal,
          ),
          PlannerTab(
            recipes: _recipes,
            entries: _mealPlan,
            onAddEntry: _addMealPlanEntry,
            onRemoveEntry: _removeMealPlanEntry,
            onAddRecipe: _addRecipe,
            onImportMealPlan: _importMealPlan,
            onGenerateGroceries: _generateGroceriesFromMealPlan,
          ),
          GroceriesTab(
            items: _groceries,
            onChanged: () {
              setState(() {});
              _storage.saveGroceries(_groceries);
            },
            onReset: _resetGroceries,
            onAddItem: _addGroceryItem,
            sourceRecipes: _groceriesSourceRecipes,
          ),
          CommunityTab(onAddToRecipes: _addRecipe),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
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
    );
  }
}
