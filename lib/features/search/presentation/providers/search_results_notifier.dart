import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/search/domain/entities/search_results_data.dart';
import 'package:pinterest/features/search/domain/entities/search_video.dart';
import 'package:pinterest/features/search/domain/usecases/search_photos_usecase.dart';
import 'package:pinterest/features/search/domain/usecases/search_videos_usecase.dart';
import 'package:pinterest/features/search/presentation/providers/search_providers.dart';
import 'package:pinterest/features/search/presentation/widgets/search_filter_bottom_sheet.dart';

/// Notifier for filtered search results with pagination.
///
/// Handles all filter types: All Pins, Videos, Boards, Profiles.
/// Listens to [searchFilterProvider] changes and re-searches accordingly.
class SearchResultsNotifier extends AsyncNotifier<SearchResultsData> {
  int _page = 1;
  bool _hasMore = true;
  String _currentQuery = '';

  // Accumulated raw data for boards/profiles regrouping on loadMore
  List<Photo> _accumulatedPhotos = [];
  List<SearchVideo> _accumulatedVideos = [];

  @override
  Future<SearchResultsData> build() async {
    return const PinResultsData([]);
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const AsyncData(PinResultsData([]));
      return;
    }

    _currentQuery = query;
    _page = 1;
    _hasMore = true;
    _accumulatedPhotos = [];
    _accumulatedVideos = [];
    state = const AsyncLoading();

    final filterType = ref.read(searchFilterProvider);

    switch (filterType) {
      case SearchFilterType.allPins:
        await _searchPhotos(query, reset: true);
      case SearchFilterType.videos:
        await _searchVideos(query, reset: true);
      case SearchFilterType.boards:
        await _searchForBoards(query, reset: true);
      case SearchFilterType.profiles:
        await _searchForProfiles(query, reset: true);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _currentQuery.isEmpty) return;

    final filterType = ref.read(searchFilterProvider);
    _page++;

    switch (filterType) {
      case SearchFilterType.allPins:
        await _searchPhotos(_currentQuery, reset: false);
      case SearchFilterType.videos:
        await _searchVideos(_currentQuery, reset: false);
      case SearchFilterType.boards:
        await _searchForBoards(_currentQuery, reset: false);
      case SearchFilterType.profiles:
        await _searchForProfiles(_currentQuery, reset: false);
    }
  }

  Future<void> _searchPhotos(String query, {required bool reset}) async {
    final useCase = ref.read(searchPhotosUseCaseProvider);
    final result = await useCase(
      SearchPhotosParams(query: query, page: _page),
    );

    state = result.fold(
      (failure) {
        if (!reset) _page--;
        return reset
            ? AsyncError(failure, StackTrace.current)
            : AsyncData(PinResultsData(_accumulatedPhotos));
      },
      (searchResult) {
        _hasMore = searchResult.hasMore;
        if (reset) {
          _accumulatedPhotos = searchResult.photos;
        } else {
          _accumulatedPhotos = [..._accumulatedPhotos, ...searchResult.photos];
        }
        return AsyncData(PinResultsData(_accumulatedPhotos));
      },
    );
  }

  Future<void> _searchVideos(String query, {required bool reset}) async {
    final useCase = ref.read(searchVideosUseCaseProvider);
    final result = await useCase(
      SearchVideosParams(query: query, page: _page),
    );

    state = result.fold(
      (failure) {
        if (!reset) _page--;
        return reset
            ? AsyncError(failure, StackTrace.current)
            : AsyncData(VideoResultsData(_accumulatedVideos));
      },
      (videoResult) {
        _hasMore = videoResult.hasMore;
        if (reset) {
          _accumulatedVideos = videoResult.videos;
        } else {
          _accumulatedVideos = [..._accumulatedVideos, ...videoResult.videos];
        }
        return AsyncData(VideoResultsData(_accumulatedVideos));
      },
    );
  }

  Future<void> _searchForBoards(String query, {required bool reset}) async {
    final useCase = ref.read(searchPhotosUseCaseProvider);
    final result = await useCase(
      SearchPhotosParams(query: query, page: _page, perPage: 30),
    );

    state = result.fold(
      (failure) {
        if (!reset) _page--;
        final boards = _groupIntoBoardsFromPhotos(_accumulatedPhotos, query);
        return reset
            ? AsyncError(failure, StackTrace.current)
            : AsyncData(BoardResultsData(boards));
      },
      (searchResult) {
        _hasMore = searchResult.hasMore;
        if (reset) {
          _accumulatedPhotos = searchResult.photos;
        } else {
          _accumulatedPhotos = [..._accumulatedPhotos, ...searchResult.photos];
        }
        final boards = _groupIntoBoardsFromPhotos(_accumulatedPhotos, query);
        return AsyncData(BoardResultsData(boards));
      },
    );
  }

  Future<void> _searchForProfiles(String query, {required bool reset}) async {
    final useCase = ref.read(searchPhotosUseCaseProvider);
    final result = await useCase(
      SearchPhotosParams(query: query, page: _page, perPage: 30),
    );

    state = result.fold(
      (failure) {
        if (!reset) _page--;
        final profiles = _groupIntoProfiles(_accumulatedPhotos);
        return reset
            ? AsyncError(failure, StackTrace.current)
            : AsyncData(ProfileResultsData(profiles));
      },
      (searchResult) {
        _hasMore = searchResult.hasMore;
        if (reset) {
          _accumulatedPhotos = searchResult.photos;
        } else {
          _accumulatedPhotos = [..._accumulatedPhotos, ...searchResult.photos];
        }
        final profiles = _groupIntoProfiles(_accumulatedPhotos);
        return AsyncData(ProfileResultsData(profiles));
      },
    );
  }

  /// Groups photos into simulated boards of 4-5 photos each.
  List<SearchBoard> _groupIntoBoardsFromPhotos(
    List<Photo> photos,
    String query,
  ) {
    if (photos.isEmpty) return [];

    final boardNames = _generateBoardNames(query);
    final boards = <SearchBoard>[];
    const photosPerBoard = 5;

    for (var i = 0; i < photos.length; i += photosPerBoard) {
      final end = (i + photosPerBoard).clamp(0, photos.length);
      final boardPhotos = photos.sublist(i, end);
      if (boardPhotos.isEmpty) break;

      final nameIndex = (i ~/ photosPerBoard) % boardNames.length;
      boards.add(
        SearchBoard(
          title: boardNames[nameIndex],
          photos: boardPhotos,
          pinCount: 20 + (i * 3),
          creatorName: boardPhotos.first.photographer,
        ),
      );
    }

    return boards;
  }

  /// Groups photos by photographer into profiles.
  List<SearchProfile> _groupIntoProfiles(List<Photo> photos) {
    if (photos.isEmpty) return [];

    final grouped = <int, List<Photo>>{};
    for (final photo in photos) {
      grouped.putIfAbsent(photo.photographerId, () => []).add(photo);
    }

    return grouped.entries.map((entry) {
      final profilePhotos = entry.value;
      return SearchProfile(
        name: profilePhotos.first.photographer,
        id: entry.key,
        url: profilePhotos.first.photographerUrl,
        photos: profilePhotos,
      );
    }).toList();
  }

  List<String> _generateBoardNames(String query) {
    final capitalized =
        query.isEmpty ? '' : '${query[0].toUpperCase()}${query.substring(1)}';
    return [
      '$capitalized Inspiration',
      '$capitalized Aesthetic',
      '$capitalized Ideas',
      '$capitalized Collection',
      'Best of $capitalized',
      '$capitalized Photography',
      'Beautiful $capitalized',
      '$capitalized Mood Board',
    ];
  }
}
