import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/search/domain/usecases/search_photos_usecase.dart';
import 'package:pinterest/features/search/presentation/providers/search_providers.dart';

/// Notifier for search results with pagination.
class SearchNotifier extends AsyncNotifier<List<Photo>> {
  int _page = 1;
  bool _hasMore = true;
  String _currentQuery = '';

  @override
  Future<List<Photo>> build() async {
    return [];
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const AsyncData([]);
      return;
    }

    _currentQuery = query;
    _page = 1;
    _hasMore = true;
    state = const AsyncLoading();

    final useCase = ref.read(searchPhotosUseCaseProvider);
    final result = await useCase(SearchPhotosParams(query: query, page: _page));

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (searchResult) {
        _hasMore = searchResult.hasMore;
        return AsyncData(searchResult.photos);
      },
    );
  }

  Future<void> loadMore() async {
    if (!_hasMore || _currentQuery.isEmpty) return;

    final current = state.valueOrNull ?? [];
    _page++;

    final useCase = ref.read(searchPhotosUseCaseProvider);
    final result = await useCase(
      SearchPhotosParams(query: _currentQuery, page: _page),
    );

    state = result.fold(
      (failure) {
        _page--;
        return AsyncData(current);
      },
      (searchResult) {
        _hasMore = searchResult.hasMore;
        return AsyncData([...current, ...searchResult.photos]);
      },
    );
  }
}
