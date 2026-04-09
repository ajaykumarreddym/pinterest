import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/settings/presentation/widgets/settings_scaffold.dart';

/// About screen — app version, credits.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'About',
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: AppSpacing.space9),
            Container(
              width: 80.w,
              height: 80.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.pinterestRed,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/pinterest.png',
                  width: 80.w,
                  height: 80.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.space5),
            Text(
              'Pinterest',
              style: AppTypography.h2.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
            SizedBox(height: AppSpacing.space2),
            Text(
              'Version 1.0.0',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiaryDark,
              ),
            ),
            SizedBox(height: AppSpacing.space9),
            _buildInfoRow('Developer', 'Pinterest Clone Team'),
            _buildInfoRow('Platform', 'Flutter'),
            _buildInfoRow('API', 'Pexels'),
            _buildInfoRow('License', 'MIT'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
