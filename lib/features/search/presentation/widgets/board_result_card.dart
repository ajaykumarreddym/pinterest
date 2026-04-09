import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/search/domain/entities/search_results_data.dart';

/// A card for displaying a simulated board search result.
///
/// Shows a collage of thumbnails with the board title, pin count,
/// and creator name.
class BoardResultCard extends StatelessWidget {
  const BoardResultCard({
    super.key,
    required this.board,
  });

  final SearchBoard board;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: AppBorders.pinCard,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo collage
          SizedBox(
            height: 180.h,
            child: _buildCollage(),
          ),

          // Board info
          Padding(
            padding: EdgeInsets.all(AppSpacing.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  board.title,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.space1),
                Row(
                  children: [
                    Text(
                      '${board.pinCount} Pins',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiaryDark,
                      ),
                    ),
                    SizedBox(width: AppSpacing.space3),
                    Text(
                      board.creatorName,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollage() {
    if (board.photos.isEmpty) {
      return Container(color: AppColors.surfaceVariantDark);
    }

    if (board.photos.length == 1) {
      return _buildImage(board.photos[0].src.medium);
    }

    if (board.photos.length == 2) {
      return Row(
        children: [
          Expanded(child: _buildImage(board.photos[0].src.medium)),
          SizedBox(width: 2.w),
          Expanded(child: _buildImage(board.photos[1].src.medium)),
        ],
      );
    }

    // 3+ photos: one large on left, two stacked on right
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildImage(board.photos[0].src.medium),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: _buildImage(board.photos[1].src.medium),
              ),
              SizedBox(height: 2.w),
              Expanded(
                child: board.photos.length > 2
                    ? _buildImage(board.photos[2].src.medium)
                    : Container(color: AppColors.surfaceVariantDark),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.surfaceDark,
        highlightColor: AppColors.surfaceVariantDark,
        child: Container(color: AppColors.surfaceVariantDark),
      ),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.surfaceVariantDark,
      ),
    );
  }
}
