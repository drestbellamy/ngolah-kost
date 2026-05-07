/// Environment configuration for the application
///
/// This class manages environment-specific variables like API keys and URLs.
/// Values are loaded from --dart-define flags during build time.
///
/// Usage:
/// ```bash
/// # Development (uses default values)
/// flutter run
///
/// # Production (uses provided values)
/// flutter build apk \
///   --dart-define=SUPABASE_URL=https://your-project.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=your-anon-key-here
/// ```
class Environment {
  /// Supabase project URL
  ///
  /// Default value is used for development only.
  /// For production builds, provide via --dart-define flag.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://dajiymvbdpmeijvrqdus.supabase.co',
  );

  /// Supabase anonymous key
  ///
  /// Default value is used for development only.
  /// For production builds, provide via --dart-define flag.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRhaml5bXZiZHBtZWlqdnJxZHVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU1MjcxNDIsImV4cCI6MjA5MTEwMzE0Mn0.C8pvRZ4U3yi-lIr-S45tUGYOoX2zgplK93ip8qMwNt0',
  );

  /// Check if running in production mode
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');

  /// Check if running in debug mode
  static bool get isDebug => !isProduction;
}
