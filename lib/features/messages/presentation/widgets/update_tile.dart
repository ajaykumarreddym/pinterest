import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/messages/domain/entities/inbox_update.dart';

/// A single update/notification row in the Updates tab.
class UpdateTile extends StatelessWidget {
  const UpdateTile({
    super.key,
    required this.update,
    this.onTap,
  });

  final InboxUpdate update;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: update.isRead
            ? Colors.transparent
            : AppColors.surfaceDark.withValues(alpha: 0.5),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space5,
          vertical: AppSpacing.space4,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(),
            SizedBox(width: AppSpacing.space4),
            Expanded(child: _buildContent()),
            if (update.thumbnailUrl != null) ...[
              SizedBox(width: AppSpacing.space3),
              _buildThumbnail(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipOval(
          child: CachedNetworkImage(
            imageUrl: update.avatarUrl,
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
                _typeIcon,
                color: AppColors.iconDefault,
                size: 20.sp,
              ),
            ),
          ),
        ),
        if (!update.isRead)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 10.w,
              height: 10.w,
              decoration: const BoxDecoration(
                color: AppColors.pinterestRed,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            children: [
              TextSpan(
                text: update.title,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight:
                      update.isRead ? FontWeight.w400 : FontWeight.w700,
                ),
              ),
              TextSpan(
                text: ' ${update.body}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          _formatTime(update.timestamp),
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: AppBorders.sm,
      child: CachedNetworkImage(
        imageUrl: update.thumbnailUrl!,
        width: 48.w,
        height: 48.w,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: AppColors.surfaceDark,
          highlightColor: AppColors.surfaceVariantDark,
          child: Container(
            width: 48.w,
            height: 48.w,
            color: AppColors.surfaceDark,
          ),
        ),
      ),
    );
  }

  IconData get _typeIcon {
    switch (update.type) {
      case InboxUpdateType.follow:
        return Icons.person_add_outlined;
      case InboxUpdateType.like:
        return Icons.favorite_border;
      case InboxUpdateType.comment:
        return Icons.chat_bubble_outline;
      case InboxUpdateType.mention:
        return Icons.alternate_email;
      case InboxUpdateType.boardInvite:
        return Icons.dashboard_outlined;
      case InboxUpdateType.trending:
        return Icons.trending_up;
      case InboxUpdateType.pinRecommendation:
        return Icons.push_pin_outlined;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
  }
}
