import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:eating_app/core/database/database_provider.dart';
import 'package:eating_app/main.dart';

void main() {
  sqfliteFfiInit();

  testWidgets('App boots and shows the three main tabs', (tester) async {
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
    await db.execute('''
      CREATE TABLE meal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        food_id INTEGER NOT NULL,
        food_name TEXT NOT NULL,
        grams REAL NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fat REAL NOT NULL,
        logged_at TEXT NOT NULL,
        log_date TEXT NOT NULL
      )
    ''');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recipes'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Diary'), findsOneWidget);

    await db.close();
  });
}
