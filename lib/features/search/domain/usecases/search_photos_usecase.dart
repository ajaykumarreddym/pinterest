import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/core/base/base_usecase.dart';
import 'package:pinterest/features/search/domain/entities/search_result.dart';
import 'package:pinterest/features/search/domain/repositories/search_repository.dart';

class SearchPhotosUseCase extends BaseUseCase<SearchPhotosParams, SearchResult> {
  SearchPhotosUseCase(this._repository);

  final SearchRepository _repository;

  @override
  Future<Either<Failure, SearchResult>> call(SearchPhotosParams params) {
    return _repository.searchPhotos(
      query: params.query,
      page: params.page,
      perPage: params.perPage,
    );
  }
}

class SearchPhotosParams extends Equatable {
  const SearchPhotosParams({
    required this.query,
    this.page = 1,
    this.perPage = 20,
  });

  final String query;
  final int page;
  final int perPage;

  @override
  List<Object?> get props => [query, page, perPage];
}
