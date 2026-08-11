import '../../domain/entities/meal_entry.dart';

class MealEntryModel extends MealEntry {
  const MealEntryModel({
    required super.id,
    required super.foodId,
    required super.foodName,
    required super.grams,
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.fat,
    required super.loggedAt,
    required super.logDate,
  });

  factory MealEntryModel.fromMap(Map<String, Object?> map) {
    return MealEntryModel(
      id: map['id']! as int,
      foodId: map['food_id']! as int,
      foodName: map['food_name']! as String,
      grams: (map['grams']! as num).toDouble(),
      calories: (map['calories']! as num).toDouble(),
      protein: (map['protein']! as num).toDouble(),
      carbs: (map['carbs']! as num).toDouble(),
      fat: (map['fat']! as num).toDouble(),
      loggedAt: DateTime.parse(map['logged_at']! as String),
      logDate: map['log_date']! as String,
    );
  }

  Map<String, Object?> toInsertMap() {
    return {
      'food_id': foodId,
      'food_name': foodName,
      'grams': grams,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'logged_at': loggedAt.toIso8601String(),
      'log_date': logDate,
    };
  }
}
