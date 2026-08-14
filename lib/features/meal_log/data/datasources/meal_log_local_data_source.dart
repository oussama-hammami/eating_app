import 'package:sqflite/sqflite.dart';

import '../models/meal_entry_model.dart';

class MealLogLocalDataSource {
  const MealLogLocalDataSource(this._db);

  final Database _db;

  Future<List<MealEntryModel>> getEntriesForDate(String logDate) async {
    final rows = await _db.query(
      'meal_entries',
      where: 'log_date = ?',
      whereArgs: [logDate],
      orderBy: 'logged_at ASC',
    );
    return rows.map(MealEntryModel.fromMap).toList();
  }

  Future<MealEntryModel> insert(MealEntryModel entry) async {
    final id = await _db.insert('meal_entries', entry.toInsertMap());
    return MealEntryModel(
      id: id,
      foodId: entry.foodId,
      foodName: entry.foodName,
      amount: entry.amount,
      unit: entry.unit,
      calories: entry.calories,
      protein: entry.protein,
      carbs: entry.carbs,
      fat: entry.fat,
      loggedAt: entry.loggedAt,
      logDate: entry.logDate,
    );
  }

  Future<MealEntryModel> getById(int entryId) async {
    final rows = await _db.query(
      'meal_entries',
      where: 'id = ?',
      whereArgs: [entryId],
      limit: 1,
    );
    return MealEntryModel.fromMap(rows.first);
  }

  Future<void> update({
    required int entryId,
    required double amount,
    required String unit,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
  }) {
    return _db.update(
      'meal_entries',
      {
        'grams': amount,
        'unit': unit,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      },
      where: 'id = ?',
      whereArgs: [entryId],
    );
  }

  Future<void> delete(int entryId) {
    return _db.delete('meal_entries', where: 'id = ?', whereArgs: [entryId]);
  }
}
