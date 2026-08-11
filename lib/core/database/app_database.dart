import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Opens the app's single sqflite database, copying the prebuilt
/// `assets/db/nutrition.db` (foods + empty meal_entries schema) into the
/// app's writable documents directory on first launch.
class AppDatabase {
  AppDatabase._(this.database);

  final Database database;

  static const String _assetPath = 'assets/db/nutrition.db';
  static const String _dbFileName = 'nutrition.db';

  static Future<AppDatabase> open() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDir.path, _dbFileName);
    final dbFile = File(dbPath);

    if (!await dbFile.exists() || !await _hasFoods(dbPath)) {
      final bytes = await rootBundle.load(_assetPath);
      await Directory(p.dirname(dbPath)).create(recursive: true);
      await dbFile.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        flush: true,
      );
    }

    final database = await openDatabase(dbPath);
    return AppDatabase._(database);
  }

  /// Guards against a stale/empty copy left behind by a previous run where
  /// the asset wasn't yet bundled (e.g. added via hot reload, which doesn't
  /// re-bundle new assets) — re-copies the asset in that case instead of
  /// silently opening a database with no `foods` rows.
  static Future<bool> _hasFoods(String dbPath) async {
    try {
      final db = await openReadOnlyDatabase(dbPath);
      try {
        final result = await db.rawQuery('SELECT COUNT(*) FROM foods');
        final count = result.first.values.first as int;
        return count > 0;
      } finally {
        await db.close();
      }
    } catch (_) {
      return false;
    }
  }

  Future<void> close() => database.close();
}
