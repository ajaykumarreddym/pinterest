import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/core/base/base_usecase.dart';
import 'package:pinterest/features/messages/domain/entities/inbox_update.dart';
import 'package:pinterest/features/messages/presentation/providers/messages_providers.dart';

/// Manages the updates/notifications list state from local cache.
class UpdatesNotifier extends AsyncNotifier<List<InboxUpdate>> {
  @override
  Future<List<InboxUpdate>> build() async {
    return _fetchUpdates();
  }

  Future<List<InboxUpdate>> _fetchUpdates() async {
    final useCase = ref.read(getUpdatesUseCaseProvider);
    final result = await useCase(const NoParams());
    return result.fold(
      (failure) => throw failure,
      (updates) => updates,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchUpdates);
  }

  Future<void> markAsRead(String updateId) async {
    final repo = ref.read(messagesRepositoryProvider);
    final result = await repo.markUpdateRead(updateId);
    result.fold(
      (_) {},
      (_) {
        final current = state.valueOrNull ?? [];
        state = AsyncData(
          current.map((u) {
            if (u.id == updateId) {
              return u.copyWith(isRead: true);
            }
            return u;
          }).toList(),
        );
      },
    );
  }

  Future<void> markAllAsRead() async {
    final useCase = ref.read(markAllUpdatesReadUseCaseProvider);
    final result = await useCase(const NoParams());
    result.fold(
      (_) {},
      (_) {
        final current = state.valueOrNull ?? [];
        state = AsyncData(
          current.map((u) => u.copyWith(isRead: true)).toList(),
        );
      },
    );
  }
}
