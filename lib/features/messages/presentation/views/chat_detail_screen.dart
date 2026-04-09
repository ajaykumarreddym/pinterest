import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/dimensions/app_dimensions.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/messages/domain/entities/conversation.dart';
import 'package:pinterest/features/messages/presentation/providers/messages_providers.dart';
import 'package:pinterest/features/messages/presentation/widgets/chat_bubble.dart';
import 'package:pinterest/features/messages/presentation/widgets/chat_input.dart';
import 'package:pinterest/features/messages/presentation/widgets/inbox_empty_state.dart';
import 'package:pinterest/features/messages/presentation/widgets/inbox_shimmer_list.dart';

/// Full conversation view with messages and input.
class ChatDetailScreen extends ConsumerStatefulWidget {
  const ChatDetailScreen({
    super.key,
    required this.conversation,
  });

  final Conversation conversation;

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync =
        ref.watch(chatDetailProvider(widget.conversation.id));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(AppDimensions.appBarHeight),
        child: _buildAppBar(context),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const InboxEmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'No messages yet',
                    subtitle: 'Send a message to start the conversation',
                  );
                }

                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    vertical: AppSpacing.space3,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final showAvatar = index == 0 ||
                        messages[index - 1].senderId != message.senderId;

                    return ChatBubble(
                      message: message,
                      showAvatar: showAvatar,
                    );
                  },
                );
              },
              loading: () => const InboxShimmerList(itemCount: 5),
              error: (error, _) => const InboxEmptyState(
                icon: Icons.error_outline,
                title: 'Something went wrong',
                subtitle: 'Could not load messages',
              ),
            ),
          ),
          ChatInput(
            onSend: (content) {
              ref
                  .read(
                      chatDetailProvider(widget.conversation.id).notifier)
                  .sendMessage(content);
              _scrollToBottom();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundDark,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.textPrimaryDark,
          size: 20.sp,
        ),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: widget.conversation.participantAvatar,
              width: AppDimensions.avatarMedium,
              height: AppDimensions.avatarMedium,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                width: AppDimensions.avatarMedium,
                height: AppDimensions.avatarMedium,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceVariantDark,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 16.sp,
                  color: AppColors.iconDefault,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Text(
              widget.conversation.participantName,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textPrimaryDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.more_vert,
            color: AppColors.textPrimaryDark,
            size: 22.sp,
          ),
        ),
      ],
    );
  }
}
