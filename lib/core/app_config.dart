class AppConfig {
  AppConfig._();

  static const supabaseUrl = String.fromEnvironment('https://loghvajgnftyyahgnnye.supabase.co');
  static const supabasePublishableKey = String.fromEnvironment(
    'sb_publishable_oHxIxO7VHPdXU1jHxMEpYg_91Tu3Rgc',
  );

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
