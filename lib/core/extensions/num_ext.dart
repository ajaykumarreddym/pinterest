import 'package:flutter/material.dart';

/// Number extensions for spacing helpers.
extension NumExt on num {
  /// Vertical SizedBox
  SizedBox get verticalSpace => SizedBox(height: toDouble());

  /// Horizontal SizedBox
  SizedBox get horizontalSpace => SizedBox(width: toDouble());
}
