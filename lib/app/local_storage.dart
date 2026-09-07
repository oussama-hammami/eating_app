import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../features/groceries/domain/entities/grocery_item.dart';
import '../features/planner/domain/entities/meal_plan_entry.dart';
import '../features/recipes/domain/entities/recipe.dart';

/// Persists the user's recipes and grocery list locally so they survive
/// app restarts, instead of living only in [RootShell]'s in-memory state.
class LocalStorage {
  static const _schemaVersionKey = 'schema_version';
  static const _schemaVersion = 1;

  static const _recipesKey = 'recipes';
  static const _groceriesKey = 'groceries';
  static const _communityRecipesCacheKey = 'community_recipes_cache';
  static const _mealPlanKey = 'meal_plan_entries';
  static const _groceriesSourceRecipeIdsKey = 'groceries_source_recipe_ids';

  /// Stamps the current schema version, so a future release can detect an
  /// older on-disk format and migrate or clear it instead of crashing.
  Future<void> ensureSchemaVersion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_schemaVersionKey, _schemaVersion);
  }

  /// Decodes [raw] as a JSON list and maps each element with [fromJson],
  /// returning an empty list if the stored data is missing, malformed, or no
  /// longer matches the expected shape — so a corrupt entry can't crash
  /// startup.
  List<T> _decodeList<T>(
    String? raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Recipe>> loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeList(prefs.getString(_recipesKey), Recipe.fromLocalJson);
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
    return _decodeList(prefs.getString(_groceriesKey), GroceryItem.fromJson);
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
    return _decodeList(
      prefs.getString(_communityRecipesCacheKey),
      Recipe.fromLocalJson,
    );
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
    return _decodeList(prefs.getString(_mealPlanKey), MealPlanEntry.fromJson);
  }

  Future<void> saveMealPlan(List<MealPlanEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _mealPlanKey,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  /// Ids of the recipes ([Recipe.id]) whose ingredients contributed to the
  /// current grocery list — so "Recipes" on the Groceries tab can show what
  /// generated it.
  Future<List<String>> loadGroceriesSourceRecipeIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_groceriesSourceRecipeIdsKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveGroceriesSourceRecipeIds(List<String> recipeIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_groceriesSourceRecipeIdsKey, jsonEncode(recipeIds));
  }
}
