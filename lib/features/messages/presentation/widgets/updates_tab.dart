import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';
import 'package:pinterest/features/messages/presentation/providers/messages_providers.dart';
import 'package:pinterest/features/messages/presentation/widgets/inbox_empty_state.dart';
import 'package:pinterest/features/messages/presentation/widgets/inbox_shimmer_list.dart';
import 'package:pinterest/features/messages/presentation/widgets/update_tile.dart';

/// The "Updates" tab content showing notifications.
class UpdatesTab extends ConsumerWidget {
  const UpdatesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatesAsync = ref.watch(updatesProvider);

    return updatesAsync.when(
      data: (updates) {
        if (updates.isEmpty) {
          return InboxEmptyState(
            icon: Icons.notifications_none,
            title: context.tr('messages.noUpdatesTitle'),
            subtitle: context.tr('messages.noUpdatesSubtitle'),
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(updatesProvider.notifier).refresh(),
          color: AppColors.pinterestRed,
          backgroundColor: AppColors.surfaceDark,
          child: ListView.separated(
            itemCount: updates.length + 1,
            separatorBuilder: (context, index) => const Divider(
              color: AppColors.dividerDark,
              height: 0.5,
            ),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildHeader(context, ref, updates);
              }
              final update = updates[index - 1];
              return UpdateTile(
                update: update,
                onTap: () {
                  ref.read(updatesProvider.notifier).markAsRead(update.id);
                },
              );
            },
          ),
        );
      },
      loading: () => const InboxShimmerList(),
      error: (error, _) => InboxEmptyState(
        icon: Icons.error_outline,
        title: context.tr('errors.generic'),
        subtitle: context.tr('general.retry'),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    List updates,
  ) {
    final hasUnread = updates.any((u) => !u.isRead);
    if (!hasUnread) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () =>
            ref.read(updatesProvider.notifier).markAllAsRead(),
        child: Text(
          context.tr('messages.markAllRead'),
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
      ),
    );
  }
}
