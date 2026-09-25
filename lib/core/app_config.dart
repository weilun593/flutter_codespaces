class AppConfig {
  AppConfig._();
  
  static const String supabaseUrl =
      'https://loghvajgnftyyahgnnye.supabase.co';


  static const String supabasePublishableKey =
      'sb_publishable_oHxIxO7VHPdXU1jHxMEpYg_91Tu3Rgc';


  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
