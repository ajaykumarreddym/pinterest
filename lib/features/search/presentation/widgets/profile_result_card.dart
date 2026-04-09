import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/search/domain/entities/search_results_data.dart';

/// A card for displaying a simulated profile search result.
///
/// Shows the photographer avatar (initial), name, and sample photos.
class ProfileResultCard extends StatelessWidget {
  const ProfileResultCard({
    super.key,
    required this.profile,
  });

  final SearchProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.space4),
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: AppBorders.pinCard,
      ),
      child: Column(
        children: [
          // Profile header
          Row(
            children: [
              // Avatar
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _avatarColor(profile.id),
                ),
                alignment: Alignment.center,
                child: Text(
                  profile.name.isNotEmpty
                      ? profile.name[0].toUpperCase()
                      : '?',
                  style: AppTypography.h3.copyWith(color: Colors.white),
                ),
              ),
              SizedBox(width: AppSpacing.space4),
              // Name and photo count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${profile.photos.length} ${profile.photos.length == 1 ? 'Pin' : 'Pins'}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.space4),

          // Sample photos grid
          if (profile.photos.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: SizedBox(
                height: 120.h,
                child: Row(
                  children: profile.photos
                      .take(3)
                      .map(
                        (photo) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 2.w),
                            child: CachedNetworkImage(
                              imageUrl: photo.src.medium,
                              fit: BoxFit.cover,
                              height: double.infinity,
                              placeholder: (_, __) => Shimmer.fromColors(
                                baseColor: AppColors.surfaceDark,
                                highlightColor: AppColors.surfaceVariantDark,
                                child: Container(
                                  color: AppColors.surfaceVariantDark,
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.surfaceVariantDark,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _avatarColor(int id) {
    const colors = [
      Color(0xFFE60023),
      Color(0xFF2D6A4F),
      Color(0xFF9B59B6),
      Color(0xFF1B4965),
      Color(0xFFE07A5F),
      Color(0xFF2A9D8F),
      Color(0xFF6D597A),
      Color(0xFFB56576),
    ];
    return colors[id % colors.length];
  }
}
