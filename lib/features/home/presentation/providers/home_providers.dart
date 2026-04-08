import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/core/di/injection.dart';
import 'package:pinterest/features/home/data/datasources/home_local_datasource.dart';
import 'package:pinterest/features/home/data/datasources/home_remote_datasource.dart';
import 'package:pinterest/features/home/data/repositories/home_repository_impl.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/home/domain/repositories/home_repository.dart';
import 'package:pinterest/features/home/domain/usecases/get_curated_photos_usecase.dart';
import 'package:pinterest/features/home/domain/usecases/search_photos_usecase.dart';
import 'package:pinterest/features/home/presentation/providers/home_notifier.dart';

// Datasources
final homeRemoteDatasourceProvider = Provider<HomeRemoteDatasource>((ref) {
  return HomeRemoteDatasourceImpl(apiClient: ref.read(apiClientProvider));
});

final homeLocalDatasourceProvider = Provider<HomeLocalDatasource>((ref) {
  return HomeLocalDatasourceImpl(storage: ref.read(appStorageProvider));
});

// Repository
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(
    remoteDatasource: ref.read(homeRemoteDatasourceProvider),
    localDatasource: ref.read(homeLocalDatasourceProvider),
  );
});

// UseCases
final getCuratedPhotosUseCaseProvider =
    Provider<GetCuratedPhotosUseCase>((ref) {
  return GetCuratedPhotosUseCase(ref.read(homeRepositoryProvider));
});

final searchPhotosUseCaseProvider = Provider<SearchPhotosUseCase>((ref) {
  return SearchPhotosUseCase(ref.read(homeRepositoryProvider));
});

// Notifiers
final homePhotosProvider =
    AsyncNotifierProvider<HomeNotifier, List<Photo>>(HomeNotifier.new);

final forYouPhotosProvider =
    AsyncNotifierProvider<ForYouNotifier, List<Photo>>(ForYouNotifier.new);
