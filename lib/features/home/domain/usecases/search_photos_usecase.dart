import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/core/base/base_usecase.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/home/domain/repositories/home_repository.dart';

class SearchPhotosParams {
  const SearchPhotosParams({
    required this.query,
    required this.page,
    this.perPage = 20,
  });

  final String query;
  final int page;
  final int perPage;
}

class SearchPhotosUseCase
    extends BaseUseCase<SearchPhotosParams, List<Photo>> {
  SearchPhotosUseCase(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Failure, List<Photo>>> call(SearchPhotosParams params) {
    return _repository.searchPhotos(
      query: params.query,
      page: params.page,
      perPage: params.perPage,
    );
  }
}
