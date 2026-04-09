import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/settings/presentation/widgets/settings_scaffold.dart';

/// Add account screen — sign in with another account.
class AddAccountScreen extends StatelessWidget {
  const AddAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Add account',
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.space5),
        child: Column(
          children: [
            SizedBox(height: AppSpacing.space7),
            Icon(
              Icons.person_add_outlined,
              size: 64.sp,
              color: AppColors.textTertiaryDark,
            ),
            SizedBox(height: AppSpacing.space5),
            Text(
              'Add another account',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
            SizedBox(height: AppSpacing.space3),
            Text(
              'Sign in with another Pinterest account to switch between them easily.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.space7),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement multi-account sign in
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Multi-account coming soon'),
                      backgroundColor: AppColors.surfaceVariantDark,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppBorders.md,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pinterestRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorders.full,
                  ),
                ),
                child: Text(
                  'Sign in',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
