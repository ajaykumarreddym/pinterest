import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';

/// A reusable outlined social login button atom (e.g. "Continue with Google").
///
/// Layout: [icon — centered label — spacer for symmetry].
/// Matches the Pinterest login design with a thin outlined border.
class AppSocialButton extends StatelessWidget {
  const AppSocialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.borderColor,
    this.borderRadius,
  });

  final String label;
  final Widget icon;
  final VoidCallback onPressed;
  final Color? borderColor;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 16.r;

    return SizedBox(
      width: double.infinity,
      height: 45.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: borderColor ?? AppColors.textSecondaryDark,
            width: 1.w,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
        ),
        child: Row(
          children: [
            icon,
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontSize: 14.sp,
                ),
              ),
            ),
            // Invisible spacer matching icon width for symmetry
            SizedBox(width: 20.w),
          ],
        ),
      ),
    );
  }
}
