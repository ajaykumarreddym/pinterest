/// Shared formatters for date and number display.
class AppFormatters {
  const AppFormatters._();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Format a number with abbreviation (e.g., 1.2K, 3.5M).
  static String compactNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  /// Format relative time (e.g., "2h ago", "3d ago").
  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 365) {
      return '${diff.inDays ~/ 365}y ago';
    }
    if (diff.inDays > 30) {
      return '${diff.inDays ~/ 30}mo ago';
    }
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    }
    if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    }
    return 'Just now';
  }

  /// Format date as "Jan 5, 2025".
  static String date(DateTime dateTime) {
    return '${_months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }
}
