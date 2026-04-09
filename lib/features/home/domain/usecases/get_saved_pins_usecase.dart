import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/core/base/base_usecase.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/home/domain/repositories/saved_pins_repository.dart';

class GetSavedPinsUseCase extends BaseUseCase<NoParams, List<Photo>> {
  GetSavedPinsUseCase(this._repository);

  final SavedPinsRepository _repository;

  @override
  Future<Either<Failure, List<Photo>>> call(NoParams params) {
    return _repository.getSavedPins();
  }
}
