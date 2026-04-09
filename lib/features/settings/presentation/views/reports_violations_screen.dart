import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/settings/presentation/widgets/settings_scaffold.dart';

/// Reports and violations centre screen.
class ReportsViolationsScreen extends StatelessWidget {
  const ReportsViolationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Reports and violations',
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.space8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flag_outlined,
                size: 64.sp,
                color: AppColors.textTertiaryDark,
              ),
              SizedBox(height: AppSpacing.space5),
              Text(
                'No reports',
                style: AppTypography.h3.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              SizedBox(height: AppSpacing.space3),
              Text(
                'Content you report will show up here. Reports help keep Pinterest safe.',
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
