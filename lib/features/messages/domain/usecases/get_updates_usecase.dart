import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/core/base/base_usecase.dart';
import 'package:pinterest/features/messages/domain/entities/inbox_update.dart';
import 'package:pinterest/features/messages/domain/repositories/messages_repository.dart';

/// Retrieves all locally cached inbox updates/notifications.
class GetUpdatesUseCase extends BaseUseCase<NoParams, List<InboxUpdate>> {
  GetUpdatesUseCase(this._repository);

  final MessagesRepository _repository;

  @override
  Future<Either<Failure, List<InboxUpdate>>> call(NoParams params) {
    return _repository.getUpdates();
  }
}
