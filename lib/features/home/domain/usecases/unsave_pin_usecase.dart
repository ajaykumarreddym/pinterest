import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/core/base/base_usecase.dart';
import 'package:pinterest/features/home/domain/repositories/saved_pins_repository.dart';

class UnsavePinUseCase extends BaseUseCase<int, void> {
  UnsavePinUseCase(this._repository);

  final SavedPinsRepository _repository;

  @override
  Future<Either<Failure, void>> call(int params) {
    return _repository.unsavePin(params);
  }
}
