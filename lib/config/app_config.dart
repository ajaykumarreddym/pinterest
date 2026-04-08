/// App-wide configuration constants.
class AppConfig {
  const AppConfig._();

  static const String appName = 'Pinterest';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;

  /// Pagination
  static const int defaultPageSize = 20;
  static const double paginationThreshold = 0.8;

  /// Image cache
  static const int maxCacheImages = 200;
  static const Duration cacheMaxAge = Duration(days: 7);

  /// API retry
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
}
