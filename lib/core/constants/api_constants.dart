/// API-related constants.
class ApiConstants {
  const ApiConstants._();

  static const String pexelsBaseUrl = 'https://api.pexels.com';
  static const String pexelsV1 = '$pexelsBaseUrl/v1';
  static const String pexelsVideos = '$pexelsBaseUrl/videos';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
}
