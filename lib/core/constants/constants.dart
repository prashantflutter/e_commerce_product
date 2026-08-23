class AppConstants {
  static const String baseUrl = 'https://dummyjson.com';
  static const String postsEndpoint = '/products';

  // Session keys
  static const String userTokenKey = 'auth_user_token';
  static const String userEmailKey = 'auth_user_email';
  static const String themeModeKey = 'app_theme_mode';

  // API timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
