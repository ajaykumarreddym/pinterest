import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/features/messages/domain/entities/message.dart';
import 'package:pinterest/features/messages/presentation/providers/messages_providers.dart';

/// Manages message list state for a specific conversation.
class ChatDetailNotifier extends FamilyAsyncNotifier<List<Message>, String> {
  @override
  Future<List<Message>> build(String conversationId) async {
    return _fetchMessages(conversationId);
  }

  Future<List<Message>> _fetchMessages(String conversationId) async {
    final useCase = ref.read(getMessagesUseCaseProvider);
    final result = await useCase(conversationId);
    return result.fold(
      (failure) => throw failure,
      (messages) => messages,
    );
  }

  Future<void> sendMessage(String content) async {
    final repo = ref.read(messagesRepositoryProvider);
    final result = await repo.sendMessage(
      conversationId: arg,
      content: content,
      type: MessageType.text,
    );
    result.fold(
      (_) {},
      (message) {
        final current = state.valueOrNull ?? [];
        state = AsyncData([...current, message]);
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchMessages(arg));
  }
}
