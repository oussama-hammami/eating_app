import 'package:eating_app/features/planner/domain/entities/meal_plan_entry.dart';
import 'package:eating_app/features/planner/domain/usecases/build_weekly_plan_pdf.dart';
import 'package:eating_app/features/recipes/domain/entities/ingredient.dart';
import 'package:eating_app/features/recipes/domain/entities/meal_type.dart';
import 'package:eating_app/features/recipes/domain/entities/recipe.dart';
import 'package:flutter_test/flutter_test.dart';

const _mealTypeLabels = {
  MealType.breakfast: 'Petit-déjeuner',
  MealType.lunch: 'Déjeuner',
  MealType.dinner: 'Dîner',
  MealType.snack: 'En-cas',
  MealType.drink: 'Boisson',
};

String _label(MealType mealType) => _mealTypeLabels[mealType]!;

void main() {
  group('buildWeeklyPlanPdf', () {
    test('generates non-empty, valid PDF bytes for a populated week', () async {
      final recipe = Recipe(
        name: 'Poulet rôti',
        calories: 450,
        protein: 35,
        portions: 4,
        ingredients: [Ingredient(name: 'Poulet', quantity: '1')],
        description: 'Rôtir au four.',
        mealType: MealType.dinner,
      );
      final weekDays = [DateTime(2026, 9, 14), DateTime(2026, 9, 15)];
      final entries = [
        MealPlanEntry(
          date: '2026-09-14',
          mealType: MealType.dinner,
          recipeId: recipe.id,
          servings: 2,
        ),
      ];

      final bytes = await buildWeeklyPlanPdf(
        weekDays: weekDays,
        weekEntries: entries,
        recipes: [recipe],
        title: 'Planning de la semaine',
        mealTypeLabel: _label,
        noMealsLabel: 'Aucun repas prévu',
      );

      expect(bytes, isNotEmpty);
      // PDF files start with the "%PDF-" magic header.
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });

    test('generates valid PDF bytes for a week with no planned meals', () async {
      final bytes = await buildWeeklyPlanPdf(
        weekDays: [DateTime(2026, 9, 14)],
        weekEntries: const [],
        recipes: const [],
        title: 'Planning vide',
        mealTypeLabel: _label,
        noMealsLabel: 'Aucun repas prévu',
      );

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });

    test('does not crash when an entry references a missing recipe id', () async {
      final entries = [
        MealPlanEntry(
          date: '2026-09-14',
          mealType: MealType.lunch,
          recipeId: 'missing-recipe-id',
          servings: 1,
        ),
      ];

      final bytes = await buildWeeklyPlanPdf(
        weekDays: [DateTime(2026, 9, 14)],
        weekEntries: entries,
        recipes: const [],
        title: 'Planning',
        mealTypeLabel: _label,
        noMealsLabel: 'Aucun repas prévu',
      );

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });
  });
}
