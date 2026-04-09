import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/messages/domain/entities/conversation.dart';

/// A single conversation row in the Messages tab.
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    this.onTap,
    this.onDismissed,
  });

  final Conversation conversation;
  final VoidCallback? onTap;
  final VoidCallback? onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: AppSpacing.space5),
        color: AppColors.pinterestRed,
        child: Icon(
          Icons.delete_outline,
          color: AppColors.textPrimaryDark,
          size: 24.sp,
        ),
      ),
      onDismissed: (_) => onDismissed?.call(),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.space5,
            vertical: AppSpacing.space4,
          ),
          child: Row(
            children: [
              _buildAvatar(),
              SizedBox(width: AppSpacing.space4),
              Expanded(child: _buildContent()),
              SizedBox(width: AppSpacing.space3),
              _buildTrailing(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: conversation.participantAvatar,
        width: 48.w,
        height: 48.w,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: AppColors.surfaceDark,
          highlightColor: AppColors.surfaceVariantDark,
          child: Container(
            width: 48.w,
            height: 48.w,
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              shape: BoxShape.circle,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 48.w,
          height: 48.w,
          decoration: const BoxDecoration(
            color: AppColors.surfaceVariantDark,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            color: AppColors.iconDefault,
            size: 24.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          conversation.participantName,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight:
                conversation.isRead ? FontWeight.w400 : FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2.h),
        if (conversation.isPinShare && conversation.sharedPinThumbnail != null)
          _buildPinSharePreview()
        else
          Text(
            conversation.lastMessage,
            style: AppTypography.bodySmall.copyWith(
              color: conversation.isRead
                  ? AppColors.textTertiaryDark
                  : AppColors.textSecondaryDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildPinSharePreview() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: AppBorders.xs,
          child: CachedNetworkImage(
            imageUrl: conversation.sharedPinThumbnail!,
            width: 28.w,
            height: 28.w,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: AppSpacing.space2),
        Expanded(
          child: Text(
            conversation.lastMessage,
            style: AppTypography.bodySmall.copyWith(
              color: conversation.isRead
                  ? AppColors.textTertiaryDark
                  : AppColors.textSecondaryDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _formatTime(conversation.lastMessageTime),
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiaryDark,
          ),
        ),
        if (!conversation.isRead && conversation.unreadCount > 0) ...[
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 6.w,
              vertical: 2.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.pinterestRed,
              borderRadius: AppBorders.full,
            ),
            child: Text(
              '${conversation.unreadCount}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${diff.inDays ~/ 7}w';
  }
}
