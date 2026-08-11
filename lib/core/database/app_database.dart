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
  /// empty (asset not yet bundled, e.g. added via hot reload), built from an
  /// older `schema_version` (e.g. before `search_name` was derived from the
  /// comma-stripped columns), or simply re-derived from updated CIQUAL data
  /// (e.g. new foods added) without any schema change. Comparing
  /// `schema_version` alone misses that last case since it's a hardcoded
  /// constant in the conversion script, not a content hash — so `food_count`
  /// is compared too, catching row additions/removals that a schema bump
  /// wouldn't.
  static Future<bool> _isUpToDate(String dbPath, ByteData assetBytes) async {
    try {
      final installedMeta = await _dbMeta(dbPath);
      final assetMeta = await _assetDbMeta(assetBytes);
      return installedMeta['schema_version'] == assetMeta['schema_version'] &&
          installedMeta['food_count'] == assetMeta['food_count'];
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, String>> _dbMeta(String dbPath) async {
    final db = await openReadOnlyDatabase(dbPath);
    try {
      final result = await db.query('db_meta');
      return {
        for (final row in result) row['key'] as String: row['value'] as String,
      };
    } finally {
      await db.close();
    }
  }

  static Future<Map<String, String>> _assetDbMeta(ByteData assetBytes) async {
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
      return await _dbMeta(tempPath);
    } finally {
      await tempFile.delete();
    }
  }

  Future<void> close() => database.close();
}
