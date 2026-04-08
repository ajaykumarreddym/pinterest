import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';

/// Create/Upload pin screen (placeholder).
class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: AppColors.iconDefault,
                size: 64.sp,
              ),
              SizedBox(height: 16.h),
              Text(
                context.tr('create.title'),
                style: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                context.tr('create.subtitle'),
                style: TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
