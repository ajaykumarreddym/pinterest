import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/search/domain/entities/search_video.dart';

/// Sealed class representing different search result types
/// based on the selected filter.
sealed class SearchResultsData {
  const SearchResultsData();
}

/// Photo/pin search results (default "All Pins" filter).
class PinResultsData extends SearchResultsData {
  const PinResultsData(this.photos);
  final List<Photo> photos;
}

/// Video search results from Pexels Video API.
class VideoResultsData extends SearchResultsData {
  const VideoResultsData(this.videos);
  final List<SearchVideo> videos;
}

/// Simulated board results derived from photo search.
class BoardResultsData extends SearchResultsData {
  const BoardResultsData(this.boards);
  final List<SearchBoard> boards;
}

/// Simulated profile results derived from photo search.
class ProfileResultsData extends SearchResultsData {
  const ProfileResultsData(this.profiles);
  final List<SearchProfile> profiles;
}

/// A simulated board grouping photos together.
class SearchBoard {
  const SearchBoard({
    required this.title,
    required this.photos,
    required this.pinCount,
    required this.creatorName,
  });

  final String title;
  final List<Photo> photos;
  final int pinCount;
  final String creatorName;
}

/// A simulated profile grouping photos by photographer.
class SearchProfile {
  const SearchProfile({
    required this.name,
    required this.id,
    required this.url,
    required this.photos,
  });

  final String name;
  final int id;
  final String url;
  final List<Photo> photos;
}
