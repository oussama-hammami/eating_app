import '../../../../core/utils/id_generator.dart';
import '../../../recipes/domain/entities/meal_type.dart';

/// One recipe assigned to one meal slot on one day of the Weekly Planner.
class MealPlanEntry {
  MealPlanEntry({
    String? id,
    required this.date,
    required this.mealType,
    required this.recipeId,
    required this.servings,
  }) : id = id ?? generateLocalId();

  final String id;

  /// ISO date string, `YYYY-MM-DD` (no time component — the planner works
  /// in whole days).
  final String date;
  final MealType mealType;

  /// [Recipe.id] of the assigned recipe. The recipe itself is looked up at
  /// render time from `RootShell._recipes` — this entry only stores the
  /// reference, so editing a recipe's details doesn't require touching the
  /// plan.
  final String recipeId;

  /// How many portions of the recipe are planned for this slot — may differ
  /// from the recipe's own [Recipe.portions], scaling nutrition/ingredients.
  final int servings;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'mealType': mealType.name,
        'recipeId': recipeId,
        'servings': servings,
      };

  factory MealPlanEntry.fromJson(Map<String, dynamic> json) => MealPlanEntry(
        id: json['id'] as String?,
        date: json['date'] as String,
        mealType: MealType.fromName(json['mealType'] as String),
        recipeId: json['recipeId'] as String,
        servings: json['servings'] as int,
      );
}
