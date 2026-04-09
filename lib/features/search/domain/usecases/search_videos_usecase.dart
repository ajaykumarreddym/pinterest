import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/core/base/base_usecase.dart';
import 'package:pinterest/features/search/domain/entities/search_video_result.dart';
import 'package:pinterest/features/search/domain/repositories/search_repository.dart';

class SearchVideosUseCase
    extends BaseUseCase<SearchVideosParams, SearchVideoResult> {
  SearchVideosUseCase(this._repository);

  final SearchRepository _repository;

  @override
  Future<Either<Failure, SearchVideoResult>> call(
    SearchVideosParams params,
  ) {
    return _repository.searchVideos(
      query: params.query,
      page: params.page,
      perPage: params.perPage,
    );
  }
}

class SearchVideosParams extends Equatable {
  const SearchVideosParams({
    required this.query,
    this.page = 1,
    this.perPage = 15,
  });

  final String query;
  final int page;
  final int perPage;

  @override
  List<Object?> get props => [query, page, perPage];
}
