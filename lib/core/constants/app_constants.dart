/// Build-time environment selector.
/// Run with: flutter run --dart-define=API_ENV=prod
const String _apiEnv = String.fromEnvironment('API_ENV', defaultValue: 'dev');

class AppConstants {
  AppConstants._();

  static const String apiEnv = _apiEnv;

  static String get baseUrl {
    switch (apiEnv) {
      case 'prod':
        return 'https://api.thewatchbox.com';
      case 'staging':
        return 'https://staging-api.thewatchbox.com';
      case 'dev':
      default:
        return 'http://localhost:4000';
    }
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
}
