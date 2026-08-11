import 'package:eating_app/core/text/text_normalizer.dart';
import 'package:eating_app/features/nutrition/data/datasources/food_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Database> _seedDatabase() async {
  final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  await db.execute('''
    CREATE TABLE foods (
      id INTEGER PRIMARY KEY,
      food_name TEXT NOT NULL,
      search_name TEXT NOT NULL,
      calories_kcal_100g REAL,
      protein_g_100g REAL,
      carbs_g_100g REAL,
      fat_g_100g REAL,
      fiber_g_100g REAL
    )
  ''');
  await db.execute('CREATE INDEX idx_foods_search_name ON foods(search_name)');

  final names = [
    'Apple, raw',
    'Apple juice',
    'Apple pie',
    'Green apple candy', // substring match for "apple", not a prefix match
    'Banana, raw',
    'Crème brûlée', // exercises accent-insensitive search
    'Zucchini',
  ];
  for (var i = 0; i < names.length; i++) {
    await db.insert('foods', {
      'id': i + 1,
      'food_name': names[i],
      'search_name': TextNormalizer.normalize(names[i]),
      'calories_kcal_100g': 100.0,
      'protein_g_100g': 1.0,
      'carbs_g_100g': 1.0,
      'fat_g_100g': 1.0,
      'fiber_g_100g': 1.0,
    });
  }
  return db;
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('prefix matches rank above substring matches, each alphabetically sorted', () async {
    final db = await _seedDatabase();
    final dataSource = FoodLocalDataSource(db);

    final results = await dataSource.search('apple', limit: 5);
    final names = results.map((f) => f.foodName).toList();

    // Prefix matches (alphabetical): Apple juice, Apple pie, Apple, raw
    // Substring-only match after: Green apple candy
    expect(names, [
      'Apple juice',
      'Apple pie',
      'Apple, raw',
      'Green apple candy',
    ]);

    await db.close();
  });

  test('caps results at the requested limit', () async {
    final db = await _seedDatabase();
    final dataSource = FoodLocalDataSource(db);

    final results = await dataSource.search('a', limit: 3);
    expect(results.length, 3);

    await db.close();
  });

  test('is case- and accent-insensitive', () async {
    final db = await _seedDatabase();
    final dataSource = FoodLocalDataSource(db);

    final byCase = await dataSource.search('APPLE');
    expect(byCase.map((f) => f.foodName), contains('Apple, raw'));

    final byAccent = await dataSource.search('creme brulee');
    expect(byAccent.map((f) => f.foodName), contains('Crème brûlée'));

    await db.close();
  });

  test('getById returns the matching food', () async {
    final db = await _seedDatabase();
    final dataSource = FoodLocalDataSource(db);

    final food = await dataSource.getById(1);
    expect(food?.foodName, 'Apple, raw');

    final missing = await dataSource.getById(999);
    expect(missing, isNull);

    await db.close();
  });
}
