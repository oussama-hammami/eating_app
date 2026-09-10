import 'dart:convert';
import 'dart:io';

import 'package:eating_app/features/planner/domain/entities/meal_plan_entry.dart';
import 'package:eating_app/features/planner/domain/meal_plan_share_codec.dart';
import 'package:eating_app/features/recipes/domain/entities/ingredient.dart';
import 'package:eating_app/features/recipes/domain/entities/meal_type.dart';
import 'package:eating_app/features/recipes/domain/entities/recipe.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirrors the codec's own encoding but wraps arbitrary JSON, so we can
/// produce a payload that survives gzip/base64 decoding but fails the
/// codec's shape validation.
String _encodeRaw(Object json) =>
    base64Url.encode(gzip.encode(utf8.encode(jsonEncode(json))));

Recipe _buildRecipe({String name = 'Omelette'}) => Recipe(
      name: name,
      calories: 300,
      protein: 20,
      portions: 1,
      ingredients: [Ingredient(name: 'Eggs', quantity: '3')],
      description: 'Beat and cook.',
      mealType: MealType.breakfast,
    );

void main() {
  group('MealPlanShareCodec', () {
    test('round-trips a week of entries plus their recipes', () {
      final recipe = _buildRecipe();
      final entries = [
        MealPlanEntry(
          date: '2026-09-14',
          mealType: MealType.breakfast,
          recipeId: recipe.id,
          servings: 2,
        ),
        MealPlanEntry(
          date: '2026-09-15',
          mealType: MealType.dinner,
          recipeId: recipe.id,
          servings: 1,
        ),
      ];

      final decoded = MealPlanShareCodec.decode(
        MealPlanShareCodec.encode(entries, [recipe]),
      );

      expect(decoded.entries, hasLength(2));
      expect(decoded.entries[0].date, '2026-09-14');
      expect(decoded.entries[0].mealType, MealType.breakfast);
      expect(decoded.entries[0].servings, 2);
      expect(decoded.entries[1].date, '2026-09-15');
      expect(decoded.entries[1].mealType, MealType.dinner);
      expect(decoded.entries[1].servings, 1);
      expect(decoded.entries.every((e) => e.recipeId == recipe.id), isTrue);

      expect(decoded.recipes, hasLength(1));
      expect(decoded.recipes.single.name, recipe.name);
      expect(decoded.recipes.single.calories, recipe.calories);
      expect(decoded.recipes.single.ingredients.single.name, 'Eggs');
    });

    test('round-trips an empty week', () {
      final decoded = MealPlanShareCodec.decode(MealPlanShareCodec.encode([], []));

      expect(decoded.entries, isEmpty);
      expect(decoded.recipes, isEmpty);
    });

    test('decoding an invalid base64/gzip payload throws a FormatException', () {
      expect(
        () => MealPlanShareCodec.decode('NotAValidPayload!!'),
        throwsFormatException,
      );
    });

    test('decoding a payload whose JSON is a list, not a plan map, throws', () {
      expect(
        () => MealPlanShareCodec.decode(_encodeRaw([])),
        throwsFormatException,
      );
    });

    test('decoding a payload missing the entries/recipes keys throws', () {
      expect(
        () => MealPlanShareCodec.decode(_encodeRaw({'foo': 'bar'})),
        throwsFormatException,
      );
    });
  });
}
