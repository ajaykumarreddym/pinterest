import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/core/base/base_usecase.dart';
import 'package:pinterest/features/messages/domain/entities/message.dart';
import 'package:pinterest/features/messages/domain/repositories/messages_repository.dart';

/// Retrieves all messages for a given conversation from local cache.
class GetMessagesUseCase extends BaseUseCase<String, List<Message>> {
  GetMessagesUseCase(this._repository);

  final MessagesRepository _repository;

  @override
  Future<Either<Failure, List<Message>>> call(String conversationId) {
    return _repository.getMessages(conversationId);
  }
}
