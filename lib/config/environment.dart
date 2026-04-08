import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Provides access to environment variables from .env file.
class Environment {
  const Environment._();

  static String get pexelsApiKey =>
      dotenv.env['PEXELS_API_KEY'] ?? '';

  static String get clerkPublishableKey =>
      dotenv.env['CLERK_PUBLISHABLE_KEY'] ?? '';

  static bool get isProduction =>
      const bool.fromEnvironment('dart.vm.product');
}
