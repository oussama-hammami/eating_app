import '../../../core/supabase/supabase_config.dart';
import '../domain/entities/recipe.dart';

/// Fetches community recipes from the `comminutyDishPropositions` table on
/// Supabase (public read via RLS — no auth required).
Future<List<Recipe>> fetchCommunityRecipes() async {
  final rows = await supabase.from('comminutyDishPropositions').select();
  return rows.map((row) => Recipe.fromSupabaseRow(row)).toList();
}
