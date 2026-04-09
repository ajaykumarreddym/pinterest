import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/messages/domain/entities/message.dart';

/// A single chat bubble in the conversation detail view.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.showAvatar,
  });

  final Message message;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: message.isMe ? 64.w : AppSpacing.space5,
        right: message.isMe ? AppSpacing.space5 : 64.w,
        top: showAvatar ? AppSpacing.space3 : 2.h,
        bottom: 2.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMe) _buildAvatarSlot(),
          if (!message.isMe) SizedBox(width: AppSpacing.space3),
          Flexible(child: _buildBubble()),
        ],
      ),
    );
  }

  Widget _buildAvatarSlot() {
    if (!showAvatar) return SizedBox(width: 28.w);

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: message.senderAvatar,
        width: 28.w,
        height: 28.w,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Container(
          width: 28.w,
          height: 28.w,
          decoration: const BoxDecoration(
            color: AppColors.surfaceVariantDark,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            size: 14.sp,
            color: AppColors.iconDefault,
          ),
        ),
      ),
    );
  }

  Widget _buildBubble() {
    if (message.type == MessageType.pinShare) {
      return _buildPinShareBubble();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space3,
      ),
      decoration: BoxDecoration(
        color: message.isMe
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.r),
          topRight: Radius.circular(18.r),
          bottomLeft: Radius.circular(message.isMe ? 18.r : 4.r),
          bottomRight: Radius.circular(message.isMe ? 4.r : 18.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            message.content,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            _formatTime(message.timestamp),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiaryDark,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinShareBubble() {
    return Container(
      decoration: BoxDecoration(
        color: message.isMe
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceDark,
        borderRadius: AppBorders.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.pinThumbnail != null)
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              child: CachedNetworkImage(
                imageUrl: message.pinThumbnail!,
                width: double.infinity,
                height: 120.h,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.space3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _formatTime(message.timestamp),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiaryDark,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
