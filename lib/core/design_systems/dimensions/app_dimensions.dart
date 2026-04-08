import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Fixed dimension values for UI components.
class AppDimensions {
  const AppDimensions._();

  // Navigation
  static double get bottomNavHeight => 56.h;
  static double get bottomNavIconSize => 24.w;
  static double get appBarHeight => 56.h;

  // Search
  static double get searchBarHeight => 48.h;

  // Grid
  static const int pinGridColumns = 2;
  static double get pinGridCrossAxisSpacing => 4.w;
  static double get pinGridMainAxisSpacing => 4.h;
  static double get pinCardMinHeight => 150.h;

  // Avatar
  static double get avatarSmall => 24.w;
  static double get avatarMedium => 32.w;
  static double get avatarLarge => 48.w;
  static double get avatarXl => 64.w;

  // FAB
  static double get fabSize => 48.w;

  // Auth buttons
  static double get authButtonHeight => 34.h;
  static double get authButtonHorizontalMargin => 24.w;
  static double get authButtonInnerPadding => 16.w;
  static double get authButtonFontSize => 14.sp;
  static double get authButtonIconSpacing => 10.w;

  // Bottom sheet
  static const double bottomSheetMaxHeightFactor = 0.9;
}
