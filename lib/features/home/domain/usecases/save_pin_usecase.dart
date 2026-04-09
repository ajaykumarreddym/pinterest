import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/core/base/base_usecase.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/home/domain/repositories/saved_pins_repository.dart';

class SavePinUseCase extends BaseUseCase<Photo, void> {
  SavePinUseCase(this._repository);

  final SavedPinsRepository _repository;

  @override
  Future<Either<Failure, void>> call(Photo params) {
    return _repository.savePin(params);
  }
}
