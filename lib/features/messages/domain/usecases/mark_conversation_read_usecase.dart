import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/core/base/base_usecase.dart';
import 'package:pinterest/features/messages/domain/repositories/messages_repository.dart';

/// Marks a conversation as read in local storage.
class MarkConversationReadUseCase extends BaseUseCase<String, void> {
  MarkConversationReadUseCase(this._repository);

  final MessagesRepository _repository;

  @override
  Future<Either<Failure, void>> call(String conversationId) {
    return _repository.markConversationRead(conversationId);
  }
}
