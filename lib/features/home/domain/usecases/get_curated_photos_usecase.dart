import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/core/base/base_usecase.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/home/domain/repositories/home_repository.dart';

class GetCuratedPhotosParams {
  const GetCuratedPhotosParams({required this.page, this.perPage = 20});

  final int page;
  final int perPage;
}

class GetCuratedPhotosUseCase
    extends BaseUseCase<GetCuratedPhotosParams, List<Photo>> {
  GetCuratedPhotosUseCase(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Failure, List<Photo>>> call(
    GetCuratedPhotosParams params,
  ) {
    return _repository.getCuratedPhotos(
      page: params.page,
      perPage: params.perPage,
    );
  }
}
