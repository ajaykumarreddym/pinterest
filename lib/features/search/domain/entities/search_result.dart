import 'package:pinterest/features/home/domain/entities/photo.dart';

/// Domain entity holding search results from Pexels API.
class SearchResult {
  const SearchResult({
    required this.query,
    required this.photos,
    required this.totalResults,
    required this.page,
    required this.hasMore,
  });

  final String query;
  final List<Photo> photos;
  final int totalResults;
  final int page;
  final bool hasMore;
}
