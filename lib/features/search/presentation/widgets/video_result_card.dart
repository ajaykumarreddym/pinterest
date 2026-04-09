import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/search/domain/entities/search_video.dart';

/// A card for displaying a video search result in the masonry grid.
///
/// Shows the video thumbnail with a play button overlay and duration badge.
class VideoResultCard extends StatelessWidget {
  const VideoResultCard({
    super.key,
    required this.video,
  });

  final SearchVideo video;

  @override
  Widget build(BuildContext context) {
    final aspectRatio = video.width / video.height;
    final cardHeight = (MediaQuery.of(context).size.width / 2) / aspectRatio;

    return ClipRRect(
      borderRadius: AppBorders.pinCard,
      child: SizedBox(
        height: cardHeight.clamp(150.h, 350.h),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail
            CachedNetworkImage(
              imageUrl: video.image,
              fit: BoxFit.cover,
              placeholder: (_, __) => Shimmer.fromColors(
                baseColor: AppColors.surfaceDark,
                highlightColor: AppColors.surfaceVariantDark,
                child: Container(color: AppColors.surfaceVariantDark),
              ),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surfaceVariantDark,
                child: Icon(
                  Icons.videocam_off,
                  color: AppColors.textTertiaryDark,
                  size: 32.sp,
                ),
              ),
            ),

            // Play button overlay
            Center(
              child: Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 28.sp,
                ),
              ),
            ),

            // Duration badge
            Positioned(
              bottom: AppSpacing.space3,
              right: AppSpacing.space3,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.space3,
                  vertical: AppSpacing.space1,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  _formatDuration(video.duration),
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Creator name
            Positioned(
              bottom: AppSpacing.space3,
              left: AppSpacing.space3,
              child: Text(
                video.userName,
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 4.r,
                      color: Colors.black54,
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
