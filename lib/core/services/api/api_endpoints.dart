/// Pexels API endpoint paths (relative to base URL).
class ApiEndpoints {
  const ApiEndpoints._();

  // Photos
  static const String curated = '/curated';
  static const String searchPhotos = '/search';
  static const String photoById = '/photos'; // append /:id

  // Videos (different base)
  static const String popularVideos = '/popular';
  static const String searchVideos = '/search';

  // Collections
  static const String collections = '/collections';
}
