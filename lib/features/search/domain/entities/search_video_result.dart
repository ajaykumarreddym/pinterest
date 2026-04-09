import 'package:pinterest/features/search/domain/entities/search_video.dart';

/// Domain entity holding video search results from Pexels API.
class SearchVideoResult {
  const SearchVideoResult({
    required this.query,
    required this.videos,
    required this.totalResults,
    required this.page,
    required this.hasMore,
  });

  final String query;
  final List<SearchVideo> videos;
  final int totalResults;
  final int page;
  final bool hasMore;
}
