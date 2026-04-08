/// Placeholder for Firebase Remote Config or similar feature flag service.
class RemoteConfig {
  const RemoteConfig._();

  // Feature flags (defaults)
  static bool get enableVisualSearch => false;
  static bool get enableAdCarousel => true;
  static bool get enableCollages => false;
}
