import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';

/// Industry-standard toast / snackbar utility.
///
/// Supports context-based and context-free (global) toast display.
/// Set [rootMessengerKey] on `MaterialApp.scaffoldMessengerKey` to enable
/// toasts that survive navigation (e.g. across bottom-sheet dismissals).
///
/// Usage:
/// ```dart
/// AppToast.success(context, message: 'Saved successfully');
/// AppToast.error(context, message: 'Something went wrong');
/// AppToast.showGlobal(message: 'Works without context', variant: ToastVariant.info);
/// ```
class AppToast {
  const AppToast._();

  /// Global key — assign to `MaterialApp.scaffoldMessengerKey`.
  static final rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

  // ─── Variants ──────────────────────────────────────────

  /// Green success toast with check icon.
  static void success(
    BuildContext? context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: const Color(0xFF1B5E20),
      iconColor: const Color(0xFF4CAF50),
      duration: duration,
    );
  }

  /// Red error toast with error icon.
  static void error(
    BuildContext? context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: AppColors.pinterestRed,
      iconColor: Colors.white,
      duration: duration,
    );
  }

  /// Neutral info toast.
  static void info(
    BuildContext? context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: AppColors.surfaceVariantDark,
      iconColor: AppColors.textSecondaryDark,
      duration: duration,
    );
  }

  /// Warning toast with amber accent.
  static void warning(
    BuildContext? context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: const Color(0xFFE65100),
      iconColor: const Color(0xFFFFB74D),
      duration: duration,
    );
  }

  // ─── Core ──────────────────────────────────────────────

  static void _show(
    BuildContext? context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required Duration duration,
  }) {
    final messenger = context != null
        ? ScaffoldMessenger.maybeOf(context)
        : null;
    final effectiveMessenger = messenger ?? rootMessengerKey.currentState;
    if (effectiveMessenger == null) return;

    effectiveMessenger.clearSnackBars();

    effectiveMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        duration: duration,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}
