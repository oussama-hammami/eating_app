import 'package:eating_app/app/local_storage.dart';
import 'package:eating_app/features/groceries/domain/entities/grocery_item.dart';
import 'package:eating_app/features/planner/domain/entities/meal_plan_entry.dart';
import 'package:eating_app/features/recipes/domain/entities/ingredient.dart';
import 'package:eating_app/features/recipes/domain/entities/meal_type.dart';
import 'package:eating_app/features/recipes/domain/entities/recipe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Recipe _buildRecipe({String name = 'Ratatouille'}) => Recipe(
      name: name,
      calories: 180,
      protein: 5,
      portions: 4,
      ingredients: [Ingredient(name: 'Courgette', quantity: '2')],
      description: 'Mijoter les légumes.',
      mealType: MealType.dinner,
      photoPath: '/local/path/ratatouille.jpg',
    );

void main() {
  setUp(() {
    // Real in-memory-backed SharedPreferences (no mocked storage functions)
    // so LocalStorage runs against its actual production persistence path.
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalStorage recipes', () {
    test('persists and reloads recipes, keeping the local photo path', () async {
      final storage = LocalStorage();
      final recipe = _buildRecipe();

      await storage.saveRecipes([recipe]);
      final reloaded = await storage.loadRecipes();

      expect(reloaded, hasLength(1));
      expect(reloaded.single.name, recipe.name);
      expect(reloaded.single.calories, recipe.calories);
      expect(reloaded.single.ingredients.single.name, 'Courgette');
      expect(reloaded.single.photoPath, recipe.photoPath);
    });

    test('loading with nothing saved yet returns an empty list', () async {
      final reloaded = await LocalStorage().loadRecipes();
      expect(reloaded, isEmpty);
    });

    test('overwrites the previously saved recipes on each save', () async {
      final storage = LocalStorage();
      await storage.saveRecipes([_buildRecipe(name: 'First')]);
      await storage.saveRecipes([_buildRecipe(name: 'Second')]);

      final reloaded = await storage.loadRecipes();
      expect(reloaded, hasLength(1));
      expect(reloaded.single.name, 'Second');
    });

    test('recovers gracefully from corrupted stored JSON', () async {
      SharedPreferences.setMockInitialValues({'recipes': '{not valid json'});
      final reloaded = await LocalStorage().loadRecipes();
      expect(reloaded, isEmpty);
    });
  });

  group('LocalStorage groceries', () {
    test('persists and reloads groceries with their raw quantities', () async {
      final storage = LocalStorage();
      final item = GroceryItem(
        name: 'Tomates',
        rawQuantities: ['200 g', '300 g'],
        checked: true,
      );

      await storage.saveGroceries([item]);
      final reloaded = await storage.loadGroceries();

      expect(reloaded, hasLength(1));
      expect(reloaded.single.name, 'Tomates');
      expect(reloaded.single.rawQuantities, ['200 g', '300 g']);
      expect(reloaded.single.checked, isTrue);
      // Exercises the real GroceryItem.displayQuantity -> combineQuantities
      // pipeline against the reloaded, persisted data.
      expect(reloaded.single.displayQuantity, '500 g');
    });
  });

  group('LocalStorage community recipes cache', () {
    test('caches and reloads community recipes as an offline fallback', () async {
      final storage = LocalStorage();
      final recipe = _buildRecipe(name: 'Community Salad');

      await storage.cacheCommunityRecipes([recipe]);
      final reloaded = await storage.loadCachedCommunityRecipes();

      expect(reloaded, hasLength(1));
      expect(reloaded.single.name, 'Community Salad');
      // Community-sourced recipes are cached via toJson/fromLocalJson, so
      // the local photo path is preserved on the same device.
      expect(reloaded.single.photoPath, recipe.photoPath);
    });
  });

  group('LocalStorage meal plan', () {
    test('persists and reloads meal plan entries across all meal slots', () async {
      final storage = LocalStorage();
      final entries = [
        MealPlanEntry(date: '2026-09-14', mealType: MealType.breakfast, recipeId: 'r1', servings: 1),
        MealPlanEntry(date: '2026-09-14', mealType: MealType.lunch, recipeId: 'r2', servings: 2),
        MealPlanEntry(date: '2026-09-14', mealType: MealType.dinner, recipeId: 'r3', servings: 4),
        MealPlanEntry(date: '2026-09-14', mealType: MealType.snack, recipeId: 'r4', servings: 1),
      ];

      await storage.saveMealPlan(entries);
      final reloaded = await storage.loadMealPlan();

      expect(reloaded, hasLength(4));
      expect(reloaded.map((e) => e.mealType), [
        MealType.breakfast,
        MealType.lunch,
        MealType.dinner,
        MealType.snack,
      ]);
      expect(reloaded.map((e) => e.recipeId), ['r1', 'r2', 'r3', 'r4']);
    });

    test('clearing the plan by saving an empty list persists as empty', () async {
      final storage = LocalStorage();
      await storage.saveMealPlan([
        MealPlanEntry(date: '2026-09-14', mealType: MealType.lunch, recipeId: 'r1', servings: 1),
      ]);
      expect(await storage.loadMealPlan(), hasLength(1));

      await storage.saveMealPlan([]);
      expect(await storage.loadMealPlan(), isEmpty);
    });
  });

  group('LocalStorage groceries source recipe ids', () {
    test('persists and reloads the recipe ids behind the grocery list', () async {
      final storage = LocalStorage();
      await storage.saveGroceriesSourceRecipeIds(['r1', 'r2', 'r3']);

      final reloaded = await storage.loadGroceriesSourceRecipeIds();
      expect(reloaded, ['r1', 'r2', 'r3']);
    });

    test('loading with nothing saved yet returns an empty list', () async {
      final reloaded = await LocalStorage().loadGroceriesSourceRecipeIds();
      expect(reloaded, isEmpty);
    });
  });

  group('LocalStorage schema version', () {
    test('ensureSchemaVersion stamps the current schema version', () async {
      await LocalStorage().ensureSchemaVersion();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('schema_version'), 1);
    });
  });
}
