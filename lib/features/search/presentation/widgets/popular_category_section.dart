import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';

/// Data model for a popular category on the search home.
class PopularCategory {
  const PopularCategory({
    required this.title,
    required this.imageUrls,
  });

  final String title;
  final List<String> imageUrls;
}

/// "Popular on Pinterest" section with title + horizontal image row.
///
/// Matches the Pinterest search home layout: "Popular on Pinterest" subtitle,
/// bold title, four horizontally-scrollable square images, and a search icon.
class PopularCategorySection extends StatelessWidget {
  const PopularCategorySection({
    super.key,
    required this.category,
    required this.onTap,
  });

  final PopularCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Popular on Pinterest" label
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.space5),
          child: Text(
            context.tr('search.popularOnPinterest'),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiaryDark,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.space1),
        // Title row with search icon
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.space5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  category.title,
                  style: AppTypography.h2.copyWith(
                    color: AppColors.textPrimaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariantDark,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.search,
                    color: AppColors.textPrimaryDark,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.space3),
        // Horizontal image row
        SizedBox(
          height: 130.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.space5),
            itemCount: category.imageUrls.length,
            separatorBuilder: (_, __) => SizedBox(width: AppSpacing.space1),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: onTap,
                child: ClipRRect(
                  borderRadius: AppBorders.sm,
                  child: CachedNetworkImage(
                    imageUrl: category.imageUrls[index],
                    width: 130.w,
                    height: 130.h,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Shimmer.fromColors(
                      baseColor: AppColors.surfaceDark,
                      highlightColor: AppColors.surfaceVariantDark,
                      child: Container(
                        width: 130.w,
                        height: 130.h,
                        color: AppColors.surfaceDark,
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 130.w,
                      height: 130.h,
                      color: AppColors.surfaceVariantDark,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.iconDefault,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
