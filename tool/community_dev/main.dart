// Standalone dev entrypoint — NOT part of the shipped app.
// Run on its own with:
//   flutter run -d chrome -t tool/community_dev/main.dart
import 'package:eating_app/core/database/app_database.dart';
import 'package:eating_app/core/database/database_provider.dart';
import 'package:eating_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'community_dev_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final appDatabase = await AppDatabase.open();

  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(appDatabase.database)],
      child: const CommunityDevApp(),
    ),
  );
}

class CommunityDevApp extends StatelessWidget {
  const CommunityDevApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community DB Dev Tool',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(useMaterial3: true),
      home: const CommunityDevScreen(),
    );
  }
}
