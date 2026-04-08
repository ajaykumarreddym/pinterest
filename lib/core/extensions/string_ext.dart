import 'package:flutter/material.dart';

/// String utility extensions.
extension StringExt on String {
  /// Converts hex color string (e.g., "#978E82") to Color.
  Color toColor() {
    final hex = replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  /// Capitalizes first letter.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
