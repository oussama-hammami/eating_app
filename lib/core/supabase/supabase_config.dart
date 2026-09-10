import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Bootstraps the Supabase client. The publishable key is public-safe
/// (protected by RLS policies) but is still kept out of source control —
/// pass it via --dart-define=SUPABASE_PUBLISHABLE_KEY=... at build/run time.
///
/// Only Supabase-backed features (currently: Community recipes) depend on
/// this. Everything else in the app is local-first, so a missing key must
/// not block the app from starting — [initialize] swallows the missing-key
/// case and leaves [isConfigured] false; callers that need Supabase (e.g.
/// [supabase]) surface their own error instead of the whole app failing to
/// launch.
class SupabaseConfig {
  static const String url = 'https://bipjodhqsldkyjoecrix.supabase.co';

  static const String publishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool isConfigured = false;

  static Future<void> initialize() async {
    if (publishableKey.isEmpty) {
      debugPrint(
        'SupabaseConfig: SUPABASE_PUBLISHABLE_KEY not set — skipping Supabase '
        'init. Features that need it (e.g. Community recipes) will show an '
        'error instead of data. Run with '
        '--dart-define=SUPABASE_PUBLISHABLE_KEY=<your-publishable-key> to enable them.',
      );
      return;
    }
    await Supabase.initialize(url: url, publishableKey: publishableKey);
    isConfigured = true;
  }
}

/// Throws a [StateError] if Supabase was never initialized (missing key) —
/// callers (community recipes fetch) already catch and surface this as a
/// normal error state rather than crashing.
SupabaseClient get supabase {
  if (!SupabaseConfig.isConfigured) {
    throw StateError(
      'Supabase is not configured (missing SUPABASE_PUBLISHABLE_KEY).',
    );
  }
  return Supabase.instance.client;
}
