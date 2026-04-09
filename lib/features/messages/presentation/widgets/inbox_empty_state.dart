import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';

/// Reusable empty state for inbox tabs.
class InboxEmptyState extends StatelessWidget {
  const InboxEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: const BoxDecoration(
                color: AppColors.surfaceDark,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.textTertiaryDark,
                size: 36.sp,
              ),
            ),
            SizedBox(height: AppSpacing.space5),
            Text(
              title,
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.space3),
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
