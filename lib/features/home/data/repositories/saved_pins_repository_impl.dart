import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_exception.dart';
import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/core/utils/app_logger.dart';
import 'package:pinterest/features/home/data/datasources/saved_pins_local_datasource.dart';
import 'package:pinterest/features/home/data/models/photo_model.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/home/domain/repositories/saved_pins_repository.dart';

class SavedPinsRepositoryImpl implements SavedPinsRepository {
  const SavedPinsRepositoryImpl({required this.localDatasource});

  final SavedPinsLocalDatasource localDatasource;

  @override
  Future<Either<Failure, void>> savePin(Photo photo) async {
    try {
      final model = PhotoModel(
        id: photo.id,
        width: photo.width,
        height: photo.height,
        url: photo.url,
        photographer: photo.photographer,
        photographerUrl: photo.photographerUrl,
        photographerId: photo.photographerId,
        avgColor: photo.avgColor,
        src: PhotoSrcModel(
          original: photo.src.original,
          large2x: photo.src.large2x,
          large: photo.src.large,
          medium: photo.src.medium,
          small: photo.src.small,
          portrait: photo.src.portrait,
          landscape: photo.src.landscape,
          tiny: photo.src.tiny,
        ),
        liked: photo.liked,
        alt: photo.alt,
      );
      await localDatasource.savePin(model);
      return const Right(null);
    } on CacheException catch (e) {
      AppLogger.error('Failed to save pin: ${e.message}');
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> unsavePin(int photoId) async {
    try {
      await localDatasource.unsavePin(photoId);
      return const Right(null);
    } on CacheException catch (e) {
      AppLogger.error('Failed to unsave pin: ${e.message}');
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Photo>>> getSavedPins() async {
    try {
      final models = localDatasource.getSavedPins();
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      AppLogger.error('Failed to get saved pins: ${e.message}');
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  bool isPinSaved(int photoId) => localDatasource.isPinSaved(photoId);
}
