import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_exception.dart';
import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/features/search/data/datasources/search_remote_datasource.dart';
import 'package:pinterest/features/search/domain/entities/search_result.dart';
import 'package:pinterest/features/search/domain/entities/search_video_result.dart';
import 'package:pinterest/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  const SearchRepositoryImpl({required this.remoteDatasource});

  final SearchRemoteDatasource remoteDatasource;

  @override
  Future<Either<Failure, SearchResult>> searchPhotos({
    required String query,
    required int page,
    int perPage = 20,
  }) async {
    try {
      final response = await remoteDatasource.searchPhotos(
        query: query,
        page: page,
        perPage: perPage,
      );

      final photos = response.photos.map((m) => m.toEntity()).toList();

      return Right(
        SearchResult(
          query: query,
          photos: photos,
          totalResults: response.totalResults,
          page: response.page,
          hasMore: photos.length >= perPage,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SearchVideoResult>> searchVideos({
    required String query,
    required int page,
    int perPage = 15,
  }) async {
    try {
      final response = await remoteDatasource.searchVideos(
        query: query,
        page: page,
        perPage: perPage,
      );

      final videos = response.videos.map((m) => m.toEntity()).toList();

      return Right(
        SearchVideoResult(
          query: query,
          videos: videos,
          totalResults: response.totalResults,
          page: response.page,
          hasMore: videos.length >= perPage,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
