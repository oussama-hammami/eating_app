import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/root_shell.dart';
import 'core/supabase/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/recipes/data/community_recipes_repository.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.communityRecipesRepository});

  /// Forwarded to [RootShell]/[CommunityTab] — overridable (e.g. in tests)
  /// so mounting the app doesn't require a live Supabase setup.
  final CommunityRecipesRepository? communityRecipesRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlanA Table',
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: RootShell(communityRecipesRepository: communityRecipesRepository),
    );
  }
}
