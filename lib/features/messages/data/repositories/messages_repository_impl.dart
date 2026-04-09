import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_exception.dart';
import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/core/utils/app_logger.dart';
import 'package:pinterest/features/messages/data/datasources/inbox_mock_data.dart';
import 'package:pinterest/features/messages/data/datasources/messages_local_datasource.dart';
import 'package:pinterest/features/messages/data/models/message_model.dart';
import 'package:pinterest/features/messages/domain/entities/conversation.dart';
import 'package:pinterest/features/messages/domain/entities/inbox_update.dart';
import 'package:pinterest/features/messages/domain/entities/message.dart';
import 'package:pinterest/features/messages/domain/repositories/messages_repository.dart';

/// Implementation that reads/writes inbox data to local cache only.
/// Seeds mock data on first launch (empty cache).
class MessagesRepositoryImpl implements MessagesRepository {
  const MessagesRepositoryImpl({required this.localDatasource});

  final MessagesLocalDatasource localDatasource;

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    try {
      final cached = await localDatasource.getCachedConversations();
      AppLogger.info('Loaded ${cached.length} conversations from cache');
      return Right(cached.map((m) => m.toEntity()).toList());
    } on CacheException {
      // First launch — seed mock data, then return it
      AppLogger.info('No cached conversations, seeding mock data');
      final mockData = InboxMockDataGenerator.generateConversations();
      await localDatasource.cacheConversations(mockData);
      return Right(mockData.map((m) => m.toEntity()).toList());
    } catch (e, stack) {
      AppLogger.error('Failed to load conversations', error: e, stackTrace: stack);
      return const Left(CacheFailure(message: 'Failed to load conversations'));
    }
  }

  @override
  Future<Either<Failure, List<InboxUpdate>>> getUpdates() async {
    try {
      final cached = await localDatasource.getCachedUpdates();
      AppLogger.info('Loaded ${cached.length} updates from cache');
      return Right(cached.map((m) => m.toEntity()).toList());
    } on CacheException {
      AppLogger.info('No cached updates, seeding mock data');
      final mockData = InboxMockDataGenerator.generateUpdates();
      await localDatasource.cacheUpdates(mockData);
      return Right(mockData.map((m) => m.toEntity()).toList());
    } catch (e, stack) {
      AppLogger.error('Failed to load updates', error: e, stackTrace: stack);
      return const Left(CacheFailure(message: 'Failed to load updates'));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(
    String conversationId,
  ) async {
    try {
      final cached = await localDatasource.getCachedMessages(conversationId);
      AppLogger.info('Loaded ${cached.length} messages for $conversationId');
      return Right(cached.map((m) => m.toEntity()).toList());
    } on CacheException {
      AppLogger.info('No cached messages for $conversationId, seeding mock');
      final mockData =
          InboxMockDataGenerator.generateMessages(conversationId);
      await localDatasource.cacheMessages(conversationId, mockData);
      return Right(mockData.map((m) => m.toEntity()).toList());
    } catch (e, stack) {
      AppLogger.error('Failed to load messages', error: e, stackTrace: stack);
      return const Left(CacheFailure(message: 'Failed to load messages'));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String content,
    required MessageType type,
    String? imageUrl,
    String? pinId,
    String? pinThumbnail,
  }) async {
    try {
      final now = DateTime.now();
      final message = Message(
        id: 'msg_${now.millisecondsSinceEpoch}',
        conversationId: conversationId,
        senderId: 'me',
        senderName: 'You',
        senderAvatar: '',
        content: content,
        timestamp: now,
        type: type,
        isMe: true,
        imageUrl: imageUrl,
        pinId: pinId,
        pinThumbnail: pinThumbnail,
      );
      // Append to cached messages
      List<MessageModel> existing;
      try {
        existing = await localDatasource.getCachedMessages(conversationId);
      } on CacheException {
        existing = [];
      }
      existing.add(MessageModel.fromEntity(message));
      await localDatasource.cacheMessages(conversationId, existing);

      // Update conversation last message
      try {
        final conversations =
            await localDatasource.getCachedConversations();
        final updated = conversations.map((c) {
          if (c.id == conversationId) {
            return c.copyWith(
              lastMessage: content,
              lastMessageTimeMs: now.millisecondsSinceEpoch,
            );
          }
          return c;
        }).toList();
        await localDatasource.cacheConversations(updated);
      } catch (_) {
        // Non-critical — conversation list update failure
      }

      return Right(message);
    } catch (e, stack) {
      AppLogger.error('Failed to send message', error: e, stackTrace: stack);
      return const Left(CacheFailure(message: 'Failed to send message'));
    }
  }

  @override
  Future<Either<Failure, void>> markConversationRead(
    String conversationId,
  ) async {
    try {
      final cached = await localDatasource.getCachedConversations();
      final updated = cached.map((c) {
        if (c.id == conversationId) {
          return c.copyWith(isRead: true, unreadCount: 0);
        }
        return c;
      }).toList();
      await localDatasource.cacheConversations(updated);
      return const Right(null);
    } catch (e, stack) {
      AppLogger.error('Failed to mark conversation read', error: e, stackTrace: stack);
      return const Left(CacheFailure(message: 'Failed to update conversation'));
    }
  }

  @override
  Future<Either<Failure, void>> markUpdateRead(String updateId) async {
    try {
      final cached = await localDatasource.getCachedUpdates();
      final updated = cached.map((u) {
        if (u.id == updateId) {
          return u.copyWith(isRead: true);
        }
        return u;
      }).toList();
      await localDatasource.cacheUpdates(updated);
      return const Right(null);
    } catch (e, stack) {
      AppLogger.error('Failed to mark update read', error: e, stackTrace: stack);
      return const Left(CacheFailure(message: 'Failed to update notification'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllUpdatesRead() async {
    try {
      final cached = await localDatasource.getCachedUpdates();
      final updated = cached.map((u) => u.copyWith(isRead: true)).toList();
      await localDatasource.cacheUpdates(updated);
      return const Right(null);
    } catch (e, stack) {
      AppLogger.error('Failed to mark all updates read', error: e, stackTrace: stack);
      return const Left(CacheFailure(message: 'Failed to update notifications'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation(
    String conversationId,
  ) async {
    try {
      final cached = await localDatasource.getCachedConversations();
      final updated = cached.where((c) => c.id != conversationId).toList();
      await localDatasource.cacheConversations(updated);
      return const Right(null);
    } catch (e, stack) {
      AppLogger.error('Failed to delete conversation', error: e, stackTrace: stack);
      return const Left(CacheFailure(message: 'Failed to delete conversation'));
    }
  }

  @override
  Future<Either<Failure, void>> clearInbox() async {
    try {
      await localDatasource.clearAll();
      return const Right(null);
    } catch (e, stack) {
      AppLogger.error('Failed to clear inbox', error: e, stackTrace: stack);
      return const Left(CacheFailure(message: 'Failed to clear inbox'));
    }
  }
}
