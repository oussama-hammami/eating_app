import 'package:supabase_flutter/supabase_flutter.dart';

/// Bootstraps the Supabase client. The publishable key is public-safe
/// (protected by RLS policies) but is still kept out of source control —
/// pass it via --dart-define=SUPABASE_PUBLISHABLE_KEY=... at build/run time.
class SupabaseConfig {
  static const String url = 'https://bipjodhqsldkyjoecrix.supabase.co';

  static const String publishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static Future<void> initialize() async {
    if (publishableKey.isEmpty) {
      throw StateError(
        'Missing SUPABASE_PUBLISHABLE_KEY. Run with '
        '--dart-define=SUPABASE_PUBLISHABLE_KEY=<your-publishable-key>.',
      );
    }
    await Supabase.initialize(url: url, publishableKey: publishableKey);
  }
}

SupabaseClient get supabase => Supabase.instance.client;
