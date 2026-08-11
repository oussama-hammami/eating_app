import 'dart:io';
import 'dart:typed_data';

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

    final bytes = await rootBundle.load(_assetPath);

    if (!await dbFile.exists() || !await _isUpToDate(dbPath, bytes)) {
      await Directory(p.dirname(dbPath)).create(recursive: true);
      await dbFile.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        flush: true,
      );
    }

    final database = await openDatabase(dbPath);
    return AppDatabase._(database);
  }

  /// Guards against a stale copy left behind by a previous run — either
  /// empty (asset not yet bundled, e.g. added via hot reload) or built from
  /// an older `schema_version` (e.g. before `search_name` was derived from
  /// the comma-stripped columns). Compares the installed `schema_version`
  /// against the bundled asset's, re-copying on any mismatch instead of
  /// silently keeping stale `foods` data forever. `schema_version` — unlike
  /// `food_count` — changes even when rows are re-derived without the row
  /// count itself changing.
  static Future<bool> _isUpToDate(String dbPath, ByteData assetBytes) async {
    try {
      final installedVersion = await _schemaVersion(dbPath);
      final assetVersion = await _assetSchemaVersion(assetBytes);
      return installedVersion == assetVersion;
    } catch (_) {
      return false;
    }
  }

  static Future<String> _schemaVersion(String dbPath) async {
    final db = await openReadOnlyDatabase(dbPath);
    try {
      final result = await db.rawQuery(
        "SELECT value FROM db_meta WHERE key = 'schema_version'",
      );
      return result.first['value'] as String;
    } finally {
      await db.close();
    }
  }

  static Future<String> _assetSchemaVersion(ByteData assetBytes) async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = p.join(
      tempDir.path,
      '_asset_check_$_dbFileName',
    );
    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(
      assetBytes.buffer.asUint8List(assetBytes.offsetInBytes, assetBytes.lengthInBytes),
      flush: true,
    );
    try {
      return await _schemaVersion(tempPath);
    } finally {
      await tempFile.delete();
    }
  }

  Future<void> close() => database.close();
}
