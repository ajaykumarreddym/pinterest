import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_failure.dart';

/// Base use case contract.
/// [Type] is the return type, [Params] is the parameter type.
abstract class BaseUseCase<Params, Type> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use when no parameters are needed.
class NoParams {
  const NoParams();
}
