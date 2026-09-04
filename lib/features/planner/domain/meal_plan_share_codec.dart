import 'dart:convert';
import 'dart:io';

import '../../recipes/domain/entities/recipe.dart';
import 'entities/meal_plan_entry.dart';

/// A decoded shared week: the plan entries plus every recipe they reference,
/// so the receiving device can render/import the week without already
/// having those recipes.
class DecodedMealPlan {
  DecodedMealPlan({required this.entries, required this.recipes});

  final List<MealPlanEntry> entries;
  final List<Recipe> recipes;
}

/// Encodes/decodes a week of [MealPlanEntry] (plus the [Recipe]s they
/// reference) for offline sharing via QR code — JSON, gzip-compressed,
/// base64url-encoded, mirroring [RecipeShareCodec].
class MealPlanShareCodec {
  const MealPlanShareCodec._();

  static String encode(List<MealPlanEntry> entries, List<Recipe> recipes) {
    final json = jsonEncode({
      'entries': entries.map((e) => e.toJson()).toList(),
      'recipes': recipes.map((r) => r.toJson()).toList(),
    });
    final compressed = gzip.encode(utf8.encode(json));
    return base64Url.encode(compressed);
  }

  /// Throws a [FormatException] if [payload] isn't a valid encoded week.
  static DecodedMealPlan decode(String payload) {
    final compressed = base64Url.decode(base64Url.normalize(payload));
    final json = utf8.decode(gzip.decode(compressed));
    final decoded = jsonDecode(json);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Not a valid meal plan payload');
    }
    final rawEntries = decoded['entries'];
    final rawRecipes = decoded['recipes'];
    if (rawEntries is! List || rawRecipes is! List) {
      throw const FormatException('Not a valid meal plan payload');
    }
    return DecodedMealPlan(
      entries: rawEntries.map((e) => MealPlanEntry.fromJson(e as Map<String, dynamic>)).toList(),
      recipes: rawRecipes.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
