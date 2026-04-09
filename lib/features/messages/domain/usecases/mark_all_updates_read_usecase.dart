import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/core/base/base_usecase.dart';
import 'package:pinterest/features/messages/domain/repositories/messages_repository.dart';

/// Marks all updates as read in local storage.
class MarkAllUpdatesReadUseCase extends BaseUseCase<NoParams, void> {
  MarkAllUpdatesReadUseCase(this._repository);

  final MessagesRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.markAllUpdatesRead();
  }
}
