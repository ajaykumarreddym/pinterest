/// Animation and transition duration constants.
class DurationConstants {
  const DurationConstants._();

  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration shimmerPeriod = Duration(milliseconds: 1500);
  static const Duration imageFadeIn = Duration(milliseconds: 200);
  static const Duration debounceSearch = Duration(milliseconds: 500);
}
