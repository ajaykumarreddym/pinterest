import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';
import 'package:pinterest/features/messages/presentation/providers/messages_providers.dart';
import 'package:pinterest/features/messages/presentation/widgets/conversation_tile.dart';
import 'package:pinterest/features/messages/presentation/widgets/inbox_empty_state.dart';
import 'package:pinterest/features/messages/presentation/widgets/inbox_shimmer_list.dart';

/// The "Messages" tab content showing conversations.
class MessagesTab extends ConsumerWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return conversationsAsync.when(
      data: (conversations) {
        if (conversations.isEmpty) {
          return InboxEmptyState(
            icon: Icons.chat_bubble_outline,
            title: context.tr('messages.noMessagesTitle'),
            subtitle: context.tr('messages.noMessagesSubtitle'),
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(conversationsProvider.notifier).refresh(),
          color: AppColors.pinterestRed,
          backgroundColor: AppColors.surfaceDark,
          child: Column(
            children: [
              _buildNewMessageButton(context),
              Expanded(
                child: ListView.separated(
                  itemCount: conversations.length,
                  separatorBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(left: 76.w),
                    child: const Divider(
                      color: AppColors.dividerDark,
                      height: 0.5,
                    ),
                  ),
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return ConversationTile(
                      conversation: conversation,
                      onTap: () {
                        ref
                            .read(conversationsProvider.notifier)
                            .markAsRead(conversation.id);
                        context.push(
                          '/chat/${conversation.id}',
                          extra: conversation,
                        );
                      },
                      onDismissed: () {
                        ref
                            .read(conversationsProvider.notifier)
                            .deleteConversation(conversation.id);
                      },
                    );
                  },
                ),
              ),
            ],
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

  Widget _buildNewMessageButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space5,
        vertical: AppSpacing.space3,
      ),
      child: InkWell(
        borderRadius: AppBorders.xl,
        onTap: () {
          // New message action — placeholder
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.space5,
            vertical: AppSpacing.space4,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: AppBorders.xl,
          ),
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: AppColors.textSecondaryDark,
                size: 20.sp,
              ),
              SizedBox(width: AppSpacing.space3),
              Text(
                context.tr('messages.newMessage'),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
