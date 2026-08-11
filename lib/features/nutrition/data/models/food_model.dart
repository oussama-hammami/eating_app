import '../../domain/entities/food.dart';

class FoodModel extends Food {
  const FoodModel({
    required super.id,
    required super.foodName,
    required super.caloriesKcal100g,
    required super.proteinG100g,
    required super.carbsG100g,
    required super.fatG100g,
    required super.fiberG100g,
  });

  factory FoodModel.fromMap(Map<String, Object?> map) {
    return FoodModel(
      id: map['id']! as int,
      foodName: map['food_name']! as String,
      caloriesKcal100g: (map['calories_kcal_100g'] as num?)?.toDouble(),
      proteinG100g: (map['protein_g_100g'] as num?)?.toDouble(),
      carbsG100g: (map['carbs_g_100g'] as num?)?.toDouble(),
      fatG100g: (map['fat_g_100g'] as num?)?.toDouble(),
      fiberG100g: (map['fiber_g_100g'] as num?)?.toDouble(),
    );
  }
}
