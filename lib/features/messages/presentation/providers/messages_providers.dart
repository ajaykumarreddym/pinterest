import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/core/services/storage/app_storage.dart';
import 'package:pinterest/features/messages/data/datasources/messages_local_datasource.dart';
import 'package:pinterest/features/messages/data/repositories/messages_repository_impl.dart';
import 'package:pinterest/features/messages/domain/entities/conversation.dart';
import 'package:pinterest/features/messages/domain/entities/inbox_update.dart';
import 'package:pinterest/features/messages/domain/entities/message.dart';
import 'package:pinterest/features/messages/domain/repositories/messages_repository.dart';
import 'package:pinterest/features/messages/domain/usecases/get_conversations_usecase.dart';
import 'package:pinterest/features/messages/domain/usecases/get_messages_usecase.dart';
import 'package:pinterest/features/messages/domain/usecases/get_updates_usecase.dart';
import 'package:pinterest/features/messages/domain/usecases/mark_all_updates_read_usecase.dart';
import 'package:pinterest/features/messages/domain/usecases/mark_conversation_read_usecase.dart';
import 'package:pinterest/features/messages/presentation/providers/chat_detail_notifier.dart';
import 'package:pinterest/features/messages/presentation/providers/conversations_notifier.dart';
import 'package:pinterest/features/messages/presentation/providers/updates_notifier.dart';

// ──── Datasource ────
final messagesLocalDatasourceProvider =
    Provider<MessagesLocalDatasource>((ref) {
  return MessagesLocalDatasourceImpl(
    storage: ref.read(appStorageProvider),
  );
});

// ──── Repository ────
final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return MessagesRepositoryImpl(
    localDatasource: ref.read(messagesLocalDatasourceProvider),
  );
});

// ──── Use Cases ────
final getConversationsUseCaseProvider =
    Provider<GetConversationsUseCase>((ref) {
  return GetConversationsUseCase(ref.read(messagesRepositoryProvider));
});

final getUpdatesUseCaseProvider = Provider<GetUpdatesUseCase>((ref) {
  return GetUpdatesUseCase(ref.read(messagesRepositoryProvider));
});

final markConversationReadUseCaseProvider =
    Provider<MarkConversationReadUseCase>((ref) {
  return MarkConversationReadUseCase(ref.read(messagesRepositoryProvider));
});

final markAllUpdatesReadUseCaseProvider =
    Provider<MarkAllUpdatesReadUseCase>((ref) {
  return MarkAllUpdatesReadUseCase(ref.read(messagesRepositoryProvider));
});

final getMessagesUseCaseProvider = Provider<GetMessagesUseCase>((ref) {
  return GetMessagesUseCase(ref.read(messagesRepositoryProvider));
});

// ──── State ────
final conversationsProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<Conversation>>(
  ConversationsNotifier.new,
);

final updatesProvider =
    AsyncNotifierProvider<UpdatesNotifier, List<InboxUpdate>>(
  UpdatesNotifier.new,
);

/// Tracks the active inbox tab index (0 = Updates, 1 = Messages).
final inboxTabIndexProvider = StateProvider<int>((ref) => 0);

/// Chat detail messages for a specific conversation.
final chatDetailProvider = AsyncNotifierProvider.family<ChatDetailNotifier,
    List<Message>, String>(
  ChatDetailNotifier.new,
);
