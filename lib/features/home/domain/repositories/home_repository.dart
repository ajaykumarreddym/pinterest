import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';

/// Repository contract for home feed data.
abstract class HomeRepository {
  /// Fetches curated/trending photos for the home feed.
  Future<Either<Failure, List<Photo>>> getCuratedPhotos({
    required int page,
    int perPage = 20,
  });

  /// Searches photos by query (e.g. topic category).
  Future<Either<Failure, List<Photo>>> searchPhotos({
    required String query,
    required int page,
    int perPage = 20,
  });

  /// Fetches a single photo by ID.
  Future<Either<Failure, Photo>> getPhotoById({required int id});
}
