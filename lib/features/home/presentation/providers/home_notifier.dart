import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/core/constants/app_constants.dart';
import 'package:pinterest/core/utils/app_logger.dart';
import 'package:pinterest/features/auth/presentation/providers/auth_providers.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/home/domain/usecases/get_curated_photos_usecase.dart';
import 'package:pinterest/features/home/domain/usecases/search_photos_usecase.dart';
import 'package:pinterest/features/home/presentation/providers/home_providers.dart';

/// Manages home feed photo list with pagination (curated / "All" tab).
class HomeNotifier extends AsyncNotifier<List<Photo>> {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<Photo>> build() async {
    AppLogger.info('🏠 HomeNotifier.build() — fetching page 1');
    _currentPage = 1;
    _hasMore = true;
    return _fetchPhotos(page: 1);
  }

  Future<List<Photo>> _fetchPhotos({required int page}) async {
    AppLogger.info('🔄 HomeNotifier._fetchPhotos(page: $page)');
    final useCase = ref.read(getCuratedPhotosUseCaseProvider);
    final result = await useCase(
      GetCuratedPhotosParams(
        page: page,
        perPage: AppConstants.defaultPageSize,
      ),
    );
    return result.fold(
      (failure) {
        AppLogger.error('❌ HomeNotifier got failure: ${failure.message}');
        throw failure;
      },
      (photos) {
        AppLogger.info('✅ HomeNotifier got ${photos.length} photos for page $page');
        if (photos.length < AppConstants.defaultPageSize) {
          _hasMore = false;
        }
        return photos;
      },
    );
  }

  /// Loads next page appending to current list.
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;

    final currentPhotos = state.valueOrNull ?? [];
    _currentPage++;

    try {
      final newPhotos = await _fetchPhotos(page: _currentPage);
      state = AsyncData([...currentPhotos, ...newPhotos]);
    } catch (e) {
      _currentPage--;
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Refreshes feed from page 1.
  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPhotos(page: 1));
  }
}

/// Manages "For you" feed — searches Pexels using the user's
/// selected topic categories.
///
/// Unlike sequential topic fetching, this uses a Pinterest-style
/// interleaved approach: fetches a small batch from EACH topic in
/// parallel and shuffles them together so the feed feels diverse
/// and mixed, not grouped by category.
class ForYouNotifier extends AsyncNotifier<List<Photo>> {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  List<String> _topics = [];

  /// Per-topic page trackers for independent pagination.
  final Map<String, int> _topicPages = {};

  /// Random instance for Fisher-Yates shuffle with weighted interleaving.
  final _random = Random();

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<Photo>> build() async {
    final profileDs = ref.read(userProfileDatasourceProvider);
    _topics = profileDs.getSelectedTopics();
    AppLogger.info('🎯 ForYouNotifier — topics: $_topics');

    if (_topics.isEmpty) {
      // No topics selected — fall back to curated.
      final useCase = ref.read(getCuratedPhotosUseCaseProvider);
      final result = await useCase(
        const GetCuratedPhotosParams(page: 1),
      );
      return result.fold((f) => throw f, (photos) => photos);
    }

    _currentPage = 1;
    _hasMore = true;
    _topicPages.clear();
    for (final topic in _topics) {
      _topicPages[topic] = 1;
    }

    return _fetchMixedPhotos();
  }

  /// Fetches photos from multiple topics in parallel, then interleaves
  /// and shuffles them for a diverse, Pinterest-style mixed feed.
  Future<List<Photo>> _fetchMixedPhotos() async {
    if (_topics.isEmpty) return [];

    // Determine how many photos to fetch per topic.
    // We distribute the total page size across topics so the feed
    // stays mixed. Each topic gets a roughly equal share.
    final totalPerPage = AppConstants.defaultPageSize;
    final perTopic = (totalPerPage / _topics.length).ceil().clamp(3, 10);

    AppLogger.info(
      '🔀 ForYou fetching $perTopic photos each from ${_topics.length} topics',
    );

    final useCase = ref.read(searchPhotosUseCaseProvider);
    final seenIds = <int>{};

    // Fetch from all topics in parallel.
    final futures = _topics.map((topic) async {
      final page = _topicPages[topic] ?? 1;
      AppLogger.info('🔍 ForYou search: "$topic" page $page');

      final result = await useCase(
        SearchPhotosParams(
          query: topic,
          page: page,
          perPage: perTopic,
        ),
      );

      return result.fold(
        (failure) {
          AppLogger.error('❌ ForYou topic "$topic" failed: ${failure.message}');
          return <Photo>[];
        },
        (photos) {
          AppLogger.info('✅ ForYou got ${photos.length} photos for "$topic"');
          return photos;
        },
      );
    }).toList();

    final results = await Future.wait(futures);

    // Interleave results using a round-robin + shuffle approach.
    // This ensures diversity: we pick one from each topic in rotation,
    // then shuffle small groups to break any visual patterns.
    final interleaved = <Photo>[];
    final queues = results.map((list) => List<Photo>.from(list)).toList();
    var maxLen = queues.fold<int>(0, (m, q) => q.length > m ? q.length : m);

    // Round-robin pick from each topic queue.
    for (var i = 0; i < maxLen; i++) {
      for (var q = 0; q < queues.length; q++) {
        if (i < queues[q].length) {
          final photo = queues[q][i];
          if (seenIds.add(photo.id)) {
            interleaved.add(photo);
          }
        }
      }
    }

    // Apply a soft shuffle: shuffle within small windows to add variety
    // without completely destroying the interleaved balance.
    _softShuffle(interleaved, windowSize: 6);

    // Check if we've reached the end of available content.
    final totalFetched = results.fold<int>(0, (s, list) => s + list.length);
    if (totalFetched < _topics.length * perTopic * 0.5) {
      _hasMore = false;
    }

    AppLogger.info(
      '🔀 ForYou interleaved feed: ${interleaved.length} mixed photos',
    );

    return interleaved;
  }

  /// Shuffles elements within sliding windows of [windowSize] to add
  /// local variety while preserving overall topic distribution balance.
  void _softShuffle(List<Photo> list, {int windowSize = 6}) {
    for (var i = 0; i < list.length; i += windowSize ~/ 2) {
      final end = (i + windowSize).clamp(0, list.length);
      final window = list.sublist(i, end);
      window.shuffle(_random);
      list.setRange(i, end, window);
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _topics.isEmpty) return;
    _isLoadingMore = true;

    final currentPhotos = state.valueOrNull ?? [];
    _currentPage++;

    // Advance page for each topic.
    for (final topic in _topics) {
      _topicPages[topic] = (_topicPages[topic] ?? 1) + 1;
    }

    try {
      final newPhotos = await _fetchMixedPhotos();

      // Deduplicate against existing feed.
      final existingIds = currentPhotos.map((p) => p.id).toSet();
      final uniqueNew = newPhotos.where((p) => !existingIds.contains(p.id)).toList();

      state = AsyncData([...currentPhotos, ...uniqueNew]);
    } catch (e) {
      _currentPage--;
      for (final topic in _topics) {
        _topicPages[topic] = (_topicPages[topic] ?? 2) - 1;
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    _topicPages.clear();
    // Randomize starting page per topic (1–5) for varied results
    for (final topic in _topics) {
      _topicPages[topic] = _random.nextInt(5) + 1;
    }
    // Shuffle topic order for extra variety
    _topics = List<String>.from(_topics)..shuffle(_random);
    // Keep previous data visible while refreshing
    state = const AsyncLoading<List<Photo>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetchMixedPhotos());
  }
}
