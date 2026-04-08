import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_exception.dart';
import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/core/utils/app_logger.dart';
import 'package:pinterest/features/home/data/datasources/home_local_datasource.dart';
import 'package:pinterest/features/home/data/datasources/home_remote_datasource.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  final HomeRemoteDatasource remoteDatasource;
  final HomeLocalDatasource localDatasource;

  @override
  Future<Either<Failure, List<Photo>>> getCuratedPhotos({
    required int page,
    int perPage = 20,
  }) async {
    AppLogger.info('🏗️ HomeRepositoryImpl.getCuratedPhotos(page: $page)');
    try {
      final response = await remoteDatasource.getCuratedPhotos(
        page: page,
        perPage: perPage,
      );
      final photos = response.photos.map((m) => m.toEntity()).toList();
      AppLogger.info('✅ Repository returned ${photos.length} photos');

      // Cache first page for offline use
      if (page == 1) {
        await localDatasource.cacheCuratedPhotos(response.photos);
      }

      return Right(photos);
    } on NetworkException catch (e) {
      AppLogger.error('❌ Repository NetworkException: ${e.message}');
      // Fallback to cached data on network error
      try {
        final cached = await localDatasource.getCachedPhotos();
        AppLogger.info('📦 Fallback: Loaded ${cached.length} cached photos');
        return Right(cached.map((m) => m.toEntity()).toList());
      } on CacheException {
        AppLogger.error('❌ No cached data available either');
        return const Left(
          NetworkFailure(message: 'No internet connection'),
        );
      }
    } on ServerException catch (e) {
      AppLogger.error('❌ Repository ServerException: ${e.message} (${e.statusCode})');
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } on UnauthorizedException catch (e) {
      AppLogger.error('❌ Repository UnauthorizedException: ${e.message}');
      return Left(UnauthorizedFailure(message: e.message));
    } on RateLimitException catch (e) {
      AppLogger.error('❌ Repository RateLimitException: ${e.message}');
      return Left(RateLimitFailure(message: e.message));
    } catch (e, stack) {
      AppLogger.error('❌ Repository unexpected error: ${e.runtimeType}', error: e, stackTrace: stack);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Photo>>> searchPhotos({
    required String query,
    required int page,
    int perPage = 20,
  }) async {
    AppLogger.info('🔍 HomeRepositoryImpl.searchPhotos(query: "$query", page: $page)');
    try {
      final response = await remoteDatasource.searchPhotos(
        query: query,
        page: page,
        perPage: perPage,
      );
      final photos = response.photos.map((m) => m.toEntity()).toList();
      AppLogger.info('✅ Search returned ${photos.length} photos');
      return Right(photos);
    } on NetworkException {
      return const Left(NetworkFailure(message: 'No internet connection'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e, stack) {
      AppLogger.error('❌ searchPhotos unexpected error', error: e, stackTrace: stack);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Photo>> getPhotoById({required int id}) async {
    try {
      final model = await remoteDatasource.getPhotoById(id: id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } on NetworkException {
      return const Left(NetworkFailure());
    }
  }
}
