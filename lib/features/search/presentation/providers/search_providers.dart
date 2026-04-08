import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/core/di/injection.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/search/data/datasources/search_remote_datasource.dart';
import 'package:pinterest/features/search/data/repositories/search_repository_impl.dart';
import 'package:pinterest/features/search/domain/repositories/search_repository.dart';
import 'package:pinterest/features/search/domain/usecases/search_photos_usecase.dart';
import 'package:pinterest/features/search/presentation/providers/search_notifier.dart';

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

// UseCase
final searchPhotosUseCaseProvider = Provider<SearchPhotosUseCase>((ref) {
  return SearchPhotosUseCase(ref.read(searchRepositoryProvider));
});

// Notifier
final searchPhotosProvider =
    AsyncNotifierProvider<SearchNotifier, List<Photo>>(SearchNotifier.new);

// Current search query
final searchQueryProvider = StateProvider<String>((ref) => '');
