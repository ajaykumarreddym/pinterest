import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/settings/presentation/widgets/settings_scaffold.dart';

/// Claimed external accounts screen.
class ClaimedAccountsScreen extends StatelessWidget {
  const ClaimedAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Claimed accounts',
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.space8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.link_off,
                size: 64.sp,
                color: AppColors.textTertiaryDark,
              ),
              SizedBox(height: AppSpacing.space5),
              Text(
                'No claimed accounts',
                style: AppTypography.h3.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              SizedBox(height: AppSpacing.space3),
              Text(
                'Claim your website, Instagram or YouTube to get access to analytics and more.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
