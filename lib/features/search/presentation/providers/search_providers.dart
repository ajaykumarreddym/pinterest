import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/core/di/injection.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/search/data/datasources/search_remote_datasource.dart';
import 'package:pinterest/features/search/data/repositories/search_repository_impl.dart';
import 'package:pinterest/features/search/domain/entities/search_results_data.dart';
import 'package:pinterest/features/search/domain/entities/search_video.dart';
import 'package:pinterest/features/search/domain/repositories/search_repository.dart';
import 'package:pinterest/features/search/domain/usecases/search_photos_usecase.dart';
import 'package:pinterest/features/search/domain/usecases/search_videos_usecase.dart';
import 'package:pinterest/features/search/presentation/providers/search_explore_notifier.dart';
import 'package:pinterest/features/search/presentation/providers/search_notifier.dart';
import 'package:pinterest/features/search/presentation/providers/search_results_notifier.dart';
import 'package:pinterest/features/search/presentation/widgets/search_filter_bottom_sheet.dart';

// Datasource
final searchRemoteDatasourceProvider =
    Provider<SearchRemoteDatasource>((ref) {
  return SearchRemoteDatasourceImpl(apiClient: ref.read(apiClientProvider));
});

// Repository
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepositoryImpl(
    remoteDatasource: ref.read(searchRemoteDatasourceProvider),
  );
});

// Use Cases
final searchPhotosUseCaseProvider = Provider<SearchPhotosUseCase>((ref) {
  return SearchPhotosUseCase(ref.read(searchRepositoryProvider));
});

final searchVideosUseCaseProvider = Provider<SearchVideosUseCase>((ref) {
  return SearchVideosUseCase(ref.read(searchRepositoryProvider));
});

// Notifier (used by image search screen)
final searchPhotosProvider =
    AsyncNotifierProvider<SearchNotifier, List<Photo>>(SearchNotifier.new);

// Filtered search results notifier (used by search results screen)
final searchResultsProvider =
    AsyncNotifierProvider<SearchResultsNotifier, SearchResultsData>(
  SearchResultsNotifier.new,
);

// Current search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Current search filter type
final searchFilterProvider =
    StateProvider<SearchFilterType>((ref) => SearchFilterType.allPins);

// Explore data (popular categories, taste cards, featured boards)
final searchExploreProvider =
    AsyncNotifierProvider<SearchExploreNotifier, SearchExploreData>(
  SearchExploreNotifier.new,
);

// Related videos for video detail screen (family provider keyed by query)
final relatedVideosProvider =
    FutureProvider.family<List<SearchVideo>, String>((ref, query) async {
  final useCase = ref.read(searchVideosUseCaseProvider);
  final searchQuery = query.isNotEmpty ? query : 'trending';
  final result = await useCase(
    SearchVideosParams(query: searchQuery, page: 1, perPage: 10),
  );
  return result.fold(
    (failure) => throw failure,
    (videoResult) => videoResult.videos,
  );
});
