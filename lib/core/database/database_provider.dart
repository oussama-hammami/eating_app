import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

/// Overridden in `main()` once [AppDatabase.open] resolves, so every other
/// provider can depend on it synchronously.
final databaseProvider = Provider<Database>((ref) {
  throw UnimplementedError('databaseProvider must be overridden in main()');
});
