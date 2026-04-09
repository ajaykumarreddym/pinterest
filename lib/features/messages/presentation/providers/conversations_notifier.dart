import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/core/base/base_usecase.dart';
import 'package:pinterest/features/messages/domain/entities/conversation.dart';
import 'package:pinterest/features/messages/presentation/providers/messages_providers.dart';

/// Manages the conversations list state from local cache.
class ConversationsNotifier extends AsyncNotifier<List<Conversation>> {
  @override
  Future<List<Conversation>> build() async {
    return _fetchConversations();
  }

  Future<List<Conversation>> _fetchConversations() async {
    final useCase = ref.read(getConversationsUseCaseProvider);
    final result = await useCase(const NoParams());
    return result.fold(
      (failure) => throw failure,
      (conversations) => conversations,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchConversations);
  }

  Future<void> markAsRead(String conversationId) async {
    final useCase = ref.read(markConversationReadUseCaseProvider);
    final result = await useCase(conversationId);
    result.fold(
      (_) {},
      (_) {
        final current = state.valueOrNull ?? [];
        state = AsyncData(
          current.map((c) {
            if (c.id == conversationId) {
              return c.copyWith(isRead: true, unreadCount: 0);
            }
            return c;
          }).toList(),
        );
      },
    );
  }

  Future<void> deleteConversation(String conversationId) async {
    final repo = ref.read(messagesRepositoryProvider);
    final result = await repo.deleteConversation(conversationId);
    result.fold(
      (_) {},
      (_) {
        final current = state.valueOrNull ?? [];
        state = AsyncData(
          current.where((c) => c.id != conversationId).toList(),
        );
      },
    );
  }
}
