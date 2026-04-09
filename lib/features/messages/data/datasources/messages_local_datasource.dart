import 'dart:convert';

import 'package:pinterest/core/base/base_exception.dart';
import 'package:pinterest/core/constants/storage_keys.dart';
import 'package:pinterest/core/services/storage/app_storage.dart';
import 'package:pinterest/features/messages/data/models/conversation_model.dart';
import 'package:pinterest/features/messages/data/models/inbox_update_model.dart';
import 'package:pinterest/features/messages/data/models/message_model.dart';

/// Local cache datasource for inbox data.
abstract class MessagesLocalDatasource {
  Future<List<ConversationModel>> getCachedConversations();
  Future<void> cacheConversations(List<ConversationModel> conversations);
  Future<List<InboxUpdateModel>> getCachedUpdates();
  Future<void> cacheUpdates(List<InboxUpdateModel> updates);
  Future<List<MessageModel>> getCachedMessages(String conversationId);
  Future<void> cacheMessages(String conversationId, List<MessageModel> messages);
  Future<void> clearConversations();
  Future<void> clearUpdates();
  Future<void> clearAll();
}

class MessagesLocalDatasourceImpl implements MessagesLocalDatasource {
  const MessagesLocalDatasourceImpl({required this.storage});

  final AppStorage storage;

  String _messagesKey(String conversationId) =>
      '${StorageKeys.cachedMessages}_$conversationId';

  @override
  Future<List<ConversationModel>> getCachedConversations() {
    final cached = storage.getStringList(StorageKeys.cachedConversations);
    if (cached == null || cached.isEmpty) {
      throw const CacheException(message: 'No cached conversations found');
    }
    return Future.value(
      cached
          .map((s) => ConversationModel.fromJson(
                jsonDecode(s) as Map<String, dynamic>,
              ))
          .toList(),
    );
  }

  @override
  Future<void> cacheConversations(List<ConversationModel> conversations) async {
    final jsonList =
        conversations.map((c) => jsonEncode(c.toJson())).toList();
    await storage.setStringList(
      StorageKeys.cachedConversations,
      jsonList,
    );
  }

  @override
  Future<List<InboxUpdateModel>> getCachedUpdates() {
    final cached = storage.getStringList(StorageKeys.cachedInboxUpdates);
    if (cached == null || cached.isEmpty) {
      throw const CacheException(message: 'No cached updates found');
    }
    return Future.value(
      cached
          .map((s) => InboxUpdateModel.fromJson(
                jsonDecode(s) as Map<String, dynamic>,
              ))
          .toList(),
    );
  }

  @override
  Future<void> cacheUpdates(List<InboxUpdateModel> updates) async {
    final jsonList = updates.map((u) => jsonEncode(u.toJson())).toList();
    await storage.setStringList(StorageKeys.cachedInboxUpdates, jsonList);
  }

  @override
  Future<List<MessageModel>> getCachedMessages(String conversationId) {
    final cached = storage.getStringList(_messagesKey(conversationId));
    if (cached == null || cached.isEmpty) {
      throw const CacheException(message: 'No cached messages found');
    }
    return Future.value(
      cached
          .map((s) => MessageModel.fromJson(
                jsonDecode(s) as Map<String, dynamic>,
              ))
          .toList(),
    );
  }

  @override
  Future<void> cacheMessages(
    String conversationId,
    List<MessageModel> messages,
  ) async {
    final jsonList = messages.map((m) => jsonEncode(m.toJson())).toList();
    await storage.setStringList(_messagesKey(conversationId), jsonList);
  }

  @override
  Future<void> clearConversations() async {
    await storage.remove(StorageKeys.cachedConversations);
  }

  @override
  Future<void> clearUpdates() async {
    await storage.remove(StorageKeys.cachedInboxUpdates);
  }

  @override
  Future<void> clearAll() async {
    await clearConversations();
    await clearUpdates();
  }
}
