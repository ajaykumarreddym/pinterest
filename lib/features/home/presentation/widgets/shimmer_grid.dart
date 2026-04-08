import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';

/// Shimmer loading placeholder for the masonry grid.
class ShimmerGrid extends StatelessWidget {
  const ShimmerGrid({super.key, this.itemCount = 10});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      padding: EdgeInsets.all(4.w),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final heights = [200.h, 250.h, 180.h, 300.h, 220.h];
        final height = heights[index % heights.length];

        return Shimmer.fromColors(
          baseColor: AppColors.surfaceDark,
          highlightColor: AppColors.surfaceVariantDark,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: AppBorders.pinCard,
            ),
          ),
        );
      },
    );
  }
}
