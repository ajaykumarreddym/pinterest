import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';

/// Signup step 3 — Gender selection.
///
/// Shows "What is your gender?" title, subtitle, and three gray
/// option buttons (Female, Male, Specify another gender).
/// Selecting an option auto-advances to the next step.
class SignupGenderStep extends StatelessWidget {
  const SignupGenderStep({
    super.key,
    required this.onSelected,
  });

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          SizedBox(height: 16.h),

          // ── Title ──
          Text(
            context.tr('auth.whatIsYourGender'),
            textAlign: TextAlign.center,
            style: AppTypography.h2.copyWith(
              color: AppColors.textPrimaryDark,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),

          // ── Subtitle ──
          Text(
            context.tr('auth.genderSubtitle'),
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 32.h),

          // ── Female ──
          _GenderOptionButton(
            label: context.tr('auth.female'),
            onTap: () => onSelected('female'),
          ),
          SizedBox(height: 12.h),

          // ── Male ──
          _GenderOptionButton(
            label: context.tr('auth.male'),
            onTap: () => onSelected('male'),
          ),
          SizedBox(height: 12.h),

          // ── Specify another gender ──
          _GenderOptionButton(
            label: context.tr('auth.specifyAnotherGender'),
            onTap: () => onSelected('other'),
          ),
        ],
      ),
    );
  }
}

class _GenderOptionButton extends StatelessWidget {
  const _GenderOptionButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5F5F5F),
          foregroundColor: AppColors.textPrimaryDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            fontSize: 16.sp,
            color: AppColors.textPrimaryDark,
          ),
        ),
      ),
    );
  }
}
