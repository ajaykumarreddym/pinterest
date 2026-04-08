import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/core/base/base_usecase.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/pin_detail/domain/repositories/pin_detail_repository.dart';

class GetPhotoByIdUseCase extends BaseUseCase<GetPhotoByIdParams, Photo> {
  GetPhotoByIdUseCase(this._repository);

  final PinDetailRepository _repository;

  @override
  Future<Either<Failure, Photo>> call(GetPhotoByIdParams params) {
    return _repository.getPhotoById(id: params.id);
  }
}

class GetPhotoByIdParams extends Equatable {
  const GetPhotoByIdParams({required this.id});

  final int id;

  @override
  List<Object?> get props => [id];
}
