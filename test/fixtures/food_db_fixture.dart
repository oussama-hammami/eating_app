import 'package:eating_app/core/text/text_normalizer.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// A realistic slice of the real CIQUAL-shaped database, covering the exact
/// scenarios this pipeline was refactored to handle correctly: CIQUAL's
/// noun-first naming ("Yogurt, Greek-style, ewe's milk"), a plain vs.
/// prepared-dish trap ("Vanilla, pod" vs "Vanilla, alcoholic extract"), an
/// exact food_unit_conversions factor (egg -> 50g/piece), and a food with
/// no reliable per-100g nutrition (null calories/protein).
Future<Database> seedFoodDbFixture() async {
  final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  await db.execute('''
    CREATE TABLE foods (
      id INTEGER PRIMARY KEY,
      food_name TEXT NOT NULL,
      search_name TEXT NOT NULL,
      alim_nom_fr_no_comma TEXT NOT NULL DEFAULT '',
      calories_kcal_100g REAL,
      protein_g_100g REAL,
      carbs_g_100g REAL,
      fat_g_100g REAL,
      fiber_g_100g REAL
    )
  ''');
  await db.execute('CREATE INDEX idx_foods_search_name ON foods(search_name)');
  await db.execute('''
    CREATE TABLE food_unit_conversions (
      food_id INTEGER NOT NULL,
      unit TEXT NOT NULL,
      grams_per_unit REAL NOT NULL
    )
  ''');

  final foods = <Map<String, Object?>>[
    {
      'id': 1,
      'food_name': "Yogurt, Greek-style, ewe's milk",
      'calories': 124.0,
      'protein': 4.82,
    },
    {'id': 2, 'food_name': 'Vanilla, pod', 'calories': null, 'protein': null},
    {'id': 3, 'food_name': 'Vanilla, alcoholic extract', 'calories': 288.0, 'protein': 0.06},
    {'id': 4, 'food_name': 'Egg, raw', 'calories': 140.0, 'protein': 12.8},
    {'id': 5, 'food_name': 'Almond, peeled, no added salt', 'calories': 597.0, 'protein': 20.9},
    {
      'id': 6,
      'food_name': 'Peanut butter or peanut paste',
      'calories': 588.0,
      'protein': 24.6,
    },
    {'id': 7, 'food_name': 'Cinnamon, powder', 'calories': 243.0, 'protein': 3.99},
    {'id': 8, 'food_name': 'Honey', 'calories': 331.0, 'protein': 0.65},
    {'id': 9, 'food_name': 'Oat, raw', 'calories': 378.0, 'protein': 16.9},
    {'id': 10, 'food_name': 'Blueberry, raw', 'calories': 57.7, 'protein': 0.87},
    {'id': 11, 'food_name': 'Chicken, breast, meat and skin, raw', 'calories': 120.0, 'protein': 21.0},
    {'id': 12, 'food_name': 'Chicken, thigh, meat and skin, raw', 'calories': 175.0, 'protein': 18.0},
    {'id': 13, 'food_name': 'Chicken soup, prepacked', 'calories': 25.0, 'protein': 1.5},
    {'id': 14, 'food_name': 'Yogurt (average)', 'calories': 60.0, 'protein': 3.5},
    // Implausible/invalid data, for validation tests.
    {'id': 15, 'food_name': 'Suspicious negative food', 'calories': -10.0, 'protein': 5.0},
    {'id': 16, 'food_name': 'Suspicious huge food', 'calories': 5000.0, 'protein': 5.0},
    // "X must not match Y" traps: same head word, nutritionally distinct
    // product, for negative food-matching tests.
    {'id': 17, 'food_name': 'Coconut, pulp, fresh', 'calories': 354.0, 'protein': 3.3},
    {'id': 18, 'food_name': 'Coconut milk', 'calories': 152.0, 'protein': 1.5},
    {'id': 19, 'food_name': 'Egg white, raw', 'calories': 48.0, 'protein': 10.9},
    {'id': 20, 'food_name': 'Egg yolk, raw', 'calories': 322.0, 'protein': 15.9},
    {'id': 21, 'food_name': 'Bread, whole wheat', 'calories': 246.0, 'protein': 9.0},
    {'id': 22, 'food_name': 'Bread, white', 'calories': 265.0, 'protein': 9.4},
  ];

  for (final food in foods) {
    await db.insert('foods', {
      'id': food['id'],
      'food_name': food['food_name'],
      'search_name': TextNormalizer.normalize(food['food_name']! as String),
      'calories_kcal_100g': food['calories'],
      'protein_g_100g': food['protein'],
      'carbs_g_100g': food['calories'] == null ? null : 1.0,
      'fat_g_100g': food['calories'] == null ? null : 1.0,
      'fiber_g_100g': food['calories'] == null ? null : 1.0,
    });
  }

  // Egg has an exact database-sourced piece conversion (matches the real
  // fixture data: `Egg, raw` -> piece -> 50g).
  await db.insert('food_unit_conversions', {'food_id': 4, 'unit': 'piece', 'grams_per_unit': 50.0});

  return db;
}
