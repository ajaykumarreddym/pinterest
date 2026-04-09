import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';

/// Shimmer loading placeholder for inbox list items.
class InboxShimmerList extends StatelessWidget {
  const InboxShimmerList({super.key, this.itemCount = 8});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space3),
      itemBuilder: (context, index) => const _ShimmerRow(),
    );
  }
}

class _ShimmerRow extends StatelessWidget {
  const _ShimmerRow();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceDark,
      highlightColor: AppColors.surfaceVariantDark,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space5,
          vertical: AppSpacing.space4,
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48.w,
              height: 48.w,
              decoration: const BoxDecoration(
                color: AppColors.surfaceDark,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: AppSpacing.space4),
            // Text lines
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    width: 180.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.space3),
            Container(
              width: 24.w,
              height: 10.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
