import 'package:eating_app/features/recipes/domain/entities/ingredient.dart';
import 'package:eating_app/features/recipes/domain/entities/meal_type.dart';
import 'package:eating_app/features/recipes/domain/entities/recipe.dart';
import 'package:eating_app/features/sharing/domain/recipe_share_codec.dart';
import 'package:flutter_test/flutter_test.dart';

Recipe _buildRecipe({String name = 'Pancakes'}) => Recipe(
      name: name,
      calories: 420,
      protein: 12,
      portions: 2,
      ingredients: [
        Ingredient(name: 'Flour', quantity: '200 g'),
        Ingredient(name: 'Milk', quantity: '250 ml'),
      ],
      description: 'Mix and cook on a hot pan.',
      mealType: MealType.breakfast,
      photoPath: '/data/user/0/com.example/cache/pancakes.jpg',
      carbs: 55,
      fat: 14,
    );

void main() {
  group('RecipeShareCodec', () {
    test('round-trips a single recipe through encode/decode', () {
      final recipe = _buildRecipe();

      final decoded = RecipeShareCodec.decode(RecipeShareCodec.encode([recipe]));

      expect(decoded, hasLength(1));
      final result = decoded.single;
      expect(result.name, recipe.name);
      expect(result.calories, recipe.calories);
      expect(result.protein, recipe.protein);
      expect(result.portions, recipe.portions);
      expect(result.description, recipe.description);
      expect(result.mealType, recipe.mealType);
      expect(result.carbs, recipe.carbs);
      expect(result.fat, recipe.fat);
      expect(result.ingredients, hasLength(recipe.ingredients.length));
      for (var i = 0; i < recipe.ingredients.length; i++) {
        expect(result.ingredients[i].name, recipe.ingredients[i].name);
        expect(result.ingredients[i].quantity, recipe.ingredients[i].quantity);
      }
      // A shared recipe's photo path points to the sender's local
      // filesystem, so decoding intentionally nulls it out.
      expect(result.photoPath, isNull);
    });

    test('round-trips a batch of multiple recipes', () {
      final recipes = [
        _buildRecipe(name: 'Pancakes'),
        _buildRecipe(name: 'Omelette'),
        _buildRecipe(name: 'Salad'),
      ];

      final decoded = RecipeShareCodec.decode(RecipeShareCodec.encode(recipes));

      expect(decoded, hasLength(recipes.length));
      for (var i = 0; i < recipes.length; i++) {
        expect(decoded[i].name, recipes[i].name);
        expect(decoded[i].calories, recipes[i].calories);
        expect(decoded[i].protein, recipes[i].protein);
        expect(decoded[i].portions, recipes[i].portions);
        expect(decoded[i].mealType, recipes[i].mealType);
        expect(decoded[i].ingredients.length, recipes[i].ingredients.length);
        expect(decoded[i].photoPath, isNull);
      }
    });

    test('decoding an invalid payload throws a FormatException', () {
      expect(
        () => RecipeShareCodec.decode('NotABase64GzipPayload'),
        throwsFormatException,
      );
    });
  });
}
