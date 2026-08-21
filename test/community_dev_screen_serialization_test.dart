import 'package:eating_app/features/recipes/domain/entities/ingredient.dart';
import 'package:eating_app/features/recipes/domain/entities/meal_type.dart';
import 'package:eating_app/features/recipes/domain/entities/recipe.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/community_dev/community_dev_screen.dart';

void main() {
  group('dartStringLiteral', () {
    test('escapes quotes, backslashes, dollar signs, and newlines', () {
      expect(dartStringLiteral(r"it's a $test\n"), r"'it\'s a \$test\\n'");
      expect(dartStringLiteral('line one\nline two'), r"'line one\nline two'");
    });

    test('leaves plain text untouched', () {
      expect(dartStringLiteral('Greek yogurt'), "'Greek yogurt'");
    });
  });

  group('dartNumLiteral', () {
    test('renders null as the literal null', () {
      expect(dartNumLiteral(null), 'null');
    });

    test('renders a double with two decimal places', () {
      expect(dartNumLiteral(39.0), '39.00');
      expect(dartNumLiteral(12.345), '12.35');
    });
  });

  group('serializeRecipeAsDartLiteral', () {
    test('produces a Recipe(...) literal with all fields and ingredients', () {
      final recipe = Recipe(
        name: "Greek Yogurt Bowl",
        calories: 430,
        protein: 39,
        portions: 1,
        mealType: MealType.breakfast,
        description: 'Mix.\nServe.',
        ingredients: [
          Ingredient(
            name: 'Greek yogurt',
            quantity: '250 g',
            calories: 150.5,
            protein: 20,
            carbs: 5,
            fat: 2,
            fiber: 0,
          ),
          Ingredient(name: 'mystery item', quantity: '', needsConfirmation: true),
        ],
      );

      final source = serializeRecipeAsDartLiteral(recipe);

      expect(source, contains("name: 'Greek Yogurt Bowl',"));
      expect(source, contains('calories: 430,'));
      expect(source, contains('protein: 39,'));
      expect(source, contains('portions: 1,'));
      expect(source, contains('mealType: MealType.breakfast,'));
      expect(source, contains("description: 'Mix.\\nServe.',"));
      expect(source, contains("name: 'Greek yogurt',"));
      expect(source, contains("quantity: '250 g',"));
      expect(source, contains('calories: 150.50,'));
      expect(source, contains("name: 'mystery item',"));
      expect(source, contains('needsConfirmation: true,'));
      // A confidently-matched ingredient should NOT carry the flag.
      expect(
        source.split('mystery item')[0].contains('needsConfirmation'),
        isFalse,
      );
    });
  });

  group('insertRecipesIntoGeneratedSource', () {
    const template = '''
List<Recipe> devGeneratedCommunityRecipes() => [
];
''';

    test('inserts before the final "];" and preserves existing entries', () {
      final withOne = insertRecipesIntoGeneratedSource(
        template,
        [
          Recipe(
            name: 'First',
            calories: 100,
            protein: 10,
            portions: 1,
            mealType: MealType.breakfast,
            description: '',
            ingredients: const [],
          ),
        ],
      );
      expect(withOne, contains("name: 'First',"));
      expect(withOne.indexOf("name: 'First'"), lessThan(withOne.lastIndexOf('];')));

      final withTwo = insertRecipesIntoGeneratedSource(
        withOne,
        [
          Recipe(
            name: 'Second',
            calories: 200,
            protein: 20,
            portions: 1,
            mealType: MealType.lunch,
            description: '',
            ingredients: const [],
          ),
        ],
      );
      // Both entries survive — appending never drops earlier recipes.
      expect(withTwo, contains("name: 'First',"));
      expect(withTwo, contains("name: 'Second',"));
    });

    test('throws when the source has no closing "];"', () {
      expect(
        () => insertRecipesIntoGeneratedSource('not a list literal', const []),
        throwsStateError,
      );
    });
  });
}
