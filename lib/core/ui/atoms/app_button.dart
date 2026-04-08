import 'package:flutter/material.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/dimensions/app_dimensions.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';

/// A reusable full-width button atom used across the app.
///
/// Follows the Pinterest design language with rounded corners,
/// no elevation, and configurable colors. All sizing is driven
/// by [AppDimensions] tokens.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.isEnabled = true,
    this.icon,
    this.height,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final bool isEnabled;
  final Widget? icon;
  final double? height;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTypography.labelLarge.copyWith(
      fontSize: AppDimensions.authButtonFontSize,
    );

    return SizedBox(
      width: double.infinity,
      height: height ?? AppDimensions.authButtonHeight,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor:
              disabledBackgroundColor ?? backgroundColor?.withValues(alpha: 0.4),
          disabledForegroundColor:
              disabledForegroundColor ?? foregroundColor?.withValues(alpha: 0.4),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.button,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.authButtonInnerPadding,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      icon!,
                      SizedBox(width: AppDimensions.authButtonIconSpacing),
                      Text(label, style: textStyle),
                    ],
                  )
                : Text(label, style: textStyle),
      ),
    );
  }
}
