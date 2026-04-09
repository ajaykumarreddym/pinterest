import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/core/base/base_usecase.dart';
import 'package:pinterest/features/messages/domain/entities/conversation.dart';
import 'package:pinterest/features/messages/domain/repositories/messages_repository.dart';

/// Retrieves all locally cached conversations.
class GetConversationsUseCase
    extends BaseUseCase<NoParams, List<Conversation>> {
  GetConversationsUseCase(this._repository);

  final MessagesRepository _repository;

  @override
  Future<Either<Failure, List<Conversation>>> call(NoParams params) {
    return _repository.getConversations();
  }
}
