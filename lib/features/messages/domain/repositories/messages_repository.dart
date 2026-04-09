import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/features/messages/domain/entities/conversation.dart';
import 'package:pinterest/features/messages/domain/entities/inbox_update.dart';
import 'package:pinterest/features/messages/domain/entities/message.dart';

/// Contract for the messages/inbox repository.
abstract class MessagesRepository {
  /// Get all conversations from local cache.
  Future<Either<Failure, List<Conversation>>> getConversations();

  /// Get all inbox updates (notifications) from local cache.
  Future<Either<Failure, List<InboxUpdate>>> getUpdates();

  /// Get messages for a specific conversation from local cache.
  Future<Either<Failure, List<Message>>> getMessages(String conversationId);

  /// Send a message in a conversation (stores locally).
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String content,
    required MessageType type,
    String? imageUrl,
    String? pinId,
    String? pinThumbnail,
  });

  /// Mark a conversation as read.
  Future<Either<Failure, void>> markConversationRead(String conversationId);

  /// Mark an update as read.
  Future<Either<Failure, void>> markUpdateRead(String updateId);

  /// Mark all updates as read.
  Future<Either<Failure, void>> markAllUpdatesRead();

  /// Delete a conversation.
  Future<Either<Failure, void>> deleteConversation(String conversationId);

  /// Clear all cached inbox data.
  Future<Either<Failure, void>> clearInbox();
}
