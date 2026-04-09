import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/features/search/domain/entities/search_result.dart';
import 'package:pinterest/features/search/domain/entities/search_video_result.dart';

/// Repository contract for search operations.
abstract class SearchRepository {
  Future<Either<Failure, SearchResult>> searchPhotos({
    required String query,
    required int page,
    int perPage = 20,
  });

  Future<Either<Failure, SearchVideoResult>> searchVideos({
    required String query,
    required int page,
    int perPage = 15,
  });
}
