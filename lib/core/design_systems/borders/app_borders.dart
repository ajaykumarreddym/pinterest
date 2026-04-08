import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Pinterest border radius constants.
class AppBorders {
  const AppBorders._();

  static BorderRadius get none => BorderRadius.zero;
  static BorderRadius get xs => BorderRadius.circular(4.r);
  static BorderRadius get sm => BorderRadius.circular(8.r);
  static BorderRadius get md => BorderRadius.circular(12.r);
  static BorderRadius get lg => BorderRadius.circular(16.r);
  static BorderRadius get xl => BorderRadius.circular(24.r);
  static BorderRadius get full => BorderRadius.circular(999.r);

  // Pinterest-specific
  static BorderRadius get pinCard => BorderRadius.circular(16.r);
  static BorderRadius get button => BorderRadius.circular(10.r);
  static BorderRadius get searchBar => BorderRadius.circular(24.r);
  static BorderRadius get chip => BorderRadius.circular(20.r);
  static BorderRadius get bottomSheet => BorderRadius.only(
        topLeft: Radius.circular(16.r),
        topRight: Radius.circular(16.r),
      );
}
