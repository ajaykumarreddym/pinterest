import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';

/// Data model for a featured board card shown on search home.
class FeaturedBoard {
  const FeaturedBoard({
    required this.title,
    required this.creator,
    required this.pinCount,
    required this.timeAgo,
    required this.imageUrls,
    this.isVerified = false,
  });

  final String title;
  final String creator;
  final int pinCount;
  final String timeAgo;
  final List<String> imageUrls;
  final bool isVerified;
}

/// Featured board card with Pinterest-style collage layout.
///
/// Shows a 2x1 collage (one large left, one stacked right) with board
/// title, creator, pin count and time info below.
class FeaturedBoardCard extends StatelessWidget {
  const FeaturedBoardCard({
    super.key,
    required this.board,
    this.onTap,
  });

  final FeaturedBoard board;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 200.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Collage images
            SizedBox(
              height: 160.h,
              child: ClipRRect(
                borderRadius: AppBorders.lg,
                child: Row(
                  children: [
                    // Large left image
                    Expanded(
                      flex: 3,
                      child: _CollageImage(
                        imageUrl: board.imageUrls.isNotEmpty
                            ? board.imageUrls[0]
                            : '',
                      ),
                    ),
                    SizedBox(width: 2.w),
                    // Stacked right images
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Expanded(
                            child: _CollageImage(
                              imageUrl: board.imageUrls.length > 1
                                  ? board.imageUrls[1]
                                  : '',
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Expanded(
                            child: _CollageImage(
                              imageUrl: board.imageUrls.length > 2
                                  ? board.imageUrls[2]
                                  : '',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.space3),
            // Title
            Text(
              board.title,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textPrimaryDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSpacing.space1),
            // Creator + verified badge
            Row(
              children: [
                Flexible(
                  child: Text(
                    board.creator,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (board.isVerified) ...[
                  SizedBox(width: AppSpacing.space1),
                  Icon(
                    Icons.verified,
                    color: AppColors.pinterestRed,
                    size: 14.sp,
                  ),
                ],
              ],
            ),
            SizedBox(height: AppSpacing.space1),
            // Pin count + time
            Text(
              '${board.pinCount} Pins · ${board.timeAgo}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollageImage extends StatelessWidget {
  const _CollageImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(color: AppColors.surfaceVariantDark);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.surfaceDark,
        highlightColor: AppColors.surfaceVariantDark,
        child: Container(color: AppColors.surfaceDark),
      ),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.surfaceVariantDark,
        child: const Icon(
          Icons.broken_image_outlined,
          color: AppColors.iconDefault,
        ),
      ),
    );
  }
}
