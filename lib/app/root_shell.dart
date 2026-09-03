import 'package:flutter/material.dart';

import '../features/groceries/domain/entities/grocery_item.dart';
import '../features/groceries/presentation/screens/groceries_tab.dart';
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

  int _groceryResetSignal = 0;

  @override
  void initState() {
    super.initState();
    _loadPersistedState();
  }

  Future<void> _loadPersistedState() async {
    final recipes = await _storage.loadRecipes();
    final groceries = await _storage.loadGroceries();
    if (!mounted) return;
    setState(() {
      _recipes.addAll(recipes);
      _groceries.addAll(groceries);
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
      _groceryResetSignal++;
    });
    _storage.saveGroceries(_groceries);
  }

  void _addToGroceries(List<Recipe> selectedRecipes) {
    final rawQuantitiesByKey = <String, List<String>>{};
    final displayNameByKey = <String, String>{};
    final order = <String>[];

    for (final item in _groceries) {
      final key = item.name.trim().toLowerCase();
      order.add(key);
      displayNameByKey[key] = item.name;
      rawQuantitiesByKey[key] = List.of(item.rawQuantities);
    }

    for (final recipe in selectedRecipes) {
      for (final ingredient in recipe.ingredients) {
        final key = ingredient.name.trim().toLowerCase();
        if (key.isEmpty) continue;
        if (!order.contains(key)) order.add(key);
        displayNameByKey[key] = ingredient.name.trim();
        rawQuantitiesByKey.putIfAbsent(key, () => []).add(ingredient.quantity.trim());
      }
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
      _tabIndex = 1;
    });
    _storage.saveGroceries(_groceries);
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
      _tabIndex = 1;
    });
    _storage.saveGroceries(_groceries);
  }

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
          GroceriesTab(
            items: _groceries,
            onChanged: () {
              setState(() {});
              _storage.saveGroceries(_groceries);
            },
            onReset: _resetGroceries,
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
