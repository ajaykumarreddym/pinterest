import 'dart:async';

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
/// selected topic categories, rotating through them for pagination.
class ForYouNotifier extends AsyncNotifier<List<Photo>> {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  List<String> _topics = [];

  /// Index into [_topics] to rotate query per page.
  int _topicIndex = 0;

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
    _topicIndex = 0;
    _hasMore = true;
    return _fetchTopicPhotos();
  }

  Future<List<Photo>> _fetchTopicPhotos() async {
    if (_topics.isEmpty) return [];

    final query = _topics[_topicIndex % _topics.length];
    AppLogger.info('🔍 ForYou search: "$query" page $_currentPage');

    final useCase = ref.read(searchPhotosUseCaseProvider);
    final result = await useCase(
      SearchPhotosParams(
        query: query,
        page: _currentPage,
        perPage: AppConstants.defaultPageSize,
      ),
    );

    return result.fold(
      (failure) {
        AppLogger.error('❌ ForYouNotifier failure: ${failure.message}');
        throw failure;
      },
      (photos) {
        if (photos.length < AppConstants.defaultPageSize) {
          _hasMore = false;
        }
        return photos;
      },
    );
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _topics.isEmpty) return;
    _isLoadingMore = true;

    final currentPhotos = state.valueOrNull ?? [];
    _currentPage++;
    _topicIndex++;

    try {
      final newPhotos = await _fetchTopicPhotos();
      state = AsyncData([...currentPhotos, ...newPhotos]);
    } catch (e) {
      _currentPage--;
      _topicIndex--;
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _topicIndex = 0;
    _hasMore = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchTopicPhotos());
  }
}
