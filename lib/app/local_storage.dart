import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../features/groceries/domain/entities/grocery_item.dart';
import '../features/planner/domain/entities/meal_plan_entry.dart';
import '../features/recipes/domain/entities/recipe.dart';

/// Persists the user's recipes and grocery list locally so they survive
/// app restarts, instead of living only in [RootShell]'s in-memory state.
class LocalStorage {
  static const _recipesKey = 'recipes';
  static const _groceriesKey = 'groceries';
  static const _communityRecipesCacheKey = 'community_recipes_cache';
  static const _mealPlanKey = 'meal_plan_entries';

  Future<List<Recipe>> loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recipesKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => Recipe.fromLocalJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveRecipes(List<Recipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _recipesKey,
      jsonEncode(recipes.map((r) => r.toJson()).toList()),
    );
  }

  Future<List<GroceryItem>> loadGroceries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_groceriesKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => GroceryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveGroceries(List<GroceryItem> groceries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _groceriesKey,
      jsonEncode(groceries.map((g) => g.toJson()).toList()),
    );
  }

  /// Last successfully fetched batch of community recipes — used as an
  /// offline fallback when a fresh fetch fails.
  Future<List<Recipe>> loadCachedCommunityRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_communityRecipesCacheKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => Recipe.fromLocalJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> cacheCommunityRecipes(List<Recipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _communityRecipesCacheKey,
      jsonEncode(recipes.map((r) => r.toJson()).toList()),
    );
  }

  Future<List<MealPlanEntry>> loadMealPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_mealPlanKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => MealPlanEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveMealPlan(List<MealPlanEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _mealPlanKey,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }
}
