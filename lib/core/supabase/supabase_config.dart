import 'package:supabase_flutter/supabase_flutter.dart';

/// Bootstraps the Supabase client. The anon key is public-safe (protected by
/// RLS policies) but is still kept out of source control — pass it via
/// --dart-define=SUPABASE_ANON_KEY=... at build/run time.
class SupabaseConfig {
  static const String url = 'https://bipjodhqsldkyjoecrix.supabase.co';

  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static Future<void> initialize() async {
    if (anonKey.isEmpty) {
      throw StateError(
        'Missing SUPABASE_ANON_KEY. Run with '
        '--dart-define=SUPABASE_ANON_KEY=<your-anon-key>.',
      );
    }
    await Supabase.initialize(url: url, anonKey: anonKey);
  }
}

SupabaseClient get supabase => Supabase.instance.client;
