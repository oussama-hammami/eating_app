import 'dart:async';

import '../../../app/local_storage.dart';
import '../domain/entities/recipe.dart';
import 'community_recipes_remote_data_source.dart';

/// Outcome of [CommunityRecipesRepository.fetch]: the recipes to show, plus
/// whether they came from cache (a prior successful fetch) because this
/// fetch failed.
class CommunityRecipesResult {
  const CommunityRecipesResult({
    required this.recipes,
    required this.hasError,
    required this.isFromCache,
  });

  final List<Recipe> recipes;

  /// True if the fetch failed — [recipes] then falls back to cache (which
  /// may be empty).
  final bool hasError;

  /// True once a fetch has failed and [recipes] is non-empty stale cached
  /// data rather than a fresh fetch — distinct from [hasError] alone, which
  /// is also true when there's no cache to fall back to.
  final bool isFromCache;
}

/// Fetches community recipes from Supabase and caches the last successful
/// batch locally as an offline fallback — shared by the Community tab and
/// the planner's recipe picker so both apply the same cache-then-retry
/// behavior instead of duplicating it.
class CommunityRecipesRepository {
  CommunityRecipesRepository({
    LocalStorage? storage,
    Future<List<Recipe>> Function()? fetchRecipes,
  }) : _storage = storage ?? LocalStorage(),
       _fetchRecipes = fetchRecipes ?? fetchCommunityRecipes;

  final LocalStorage _storage;
  final Future<List<Recipe>> Function() _fetchRecipes;

  Future<CommunityRecipesResult> fetch() async {
    try {
      final recipes = await _fetchRecipes();
      unawaited(_storage.cacheCommunityRecipes(recipes));
      return CommunityRecipesResult(recipes: recipes, hasError: false, isFromCache: false);
    } catch (_) {
      final cached = await _storage.loadCachedCommunityRecipes();
      return CommunityRecipesResult(
        recipes: cached,
        hasError: true,
        isFromCache: cached.isNotEmpty,
      );
    }
  }
}
