/// App-wide string constants.
class AppConstants {
  AppConstants._();

  // Supported languages
  static const String defaultLanguage = 'en';
  static const List<String> supportedLanguages = ['en', 'ar', 'ckb'];
  static const Map<String, String> languageNames = {
    'en': 'English',
    'ar': 'العربية',
    'ckb': 'کوردی',
  };

  // Storage keys
  static const String keyLanguage = 'app_language';
  static const String keyClinicId = 'clinic_id';
}