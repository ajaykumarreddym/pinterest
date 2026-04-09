/// Route name constants used with GoRouter.
class RouteNames {
  const RouteNames._();

  // Auth
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String signUp = 'signUp';
  static const String emailVerification = 'emailVerification';
  static const String clerkAuth = 'clerkAuth';

  // Shell (bottom nav)
  static const String shell = 'shell';

  // Main tabs
  static const String home = 'home';
  static const String search = 'search';
  static const String create = 'create';
  static const String messages = 'messages';
  static const String profile = 'profile';

  // Detail
  static const String pinDetail = 'pinDetail';
  static const String imageSearch = 'imageSearch';
  static const String searchResults = 'searchResults';

  // Settings
  static const String settings = 'settings';
  static const String account = 'account';
}

/// Route path constants.
class RoutePaths {
  const RoutePaths._();

  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String emailVerification = '/email-verification';
  static const String clerkAuth = '/clerk-auth';
  static const String home = '/home';
  static const String search = '/search';
  static const String create = '/create';
  static const String messages = '/messages';
  static const String profile = '/profile';
  static const String pinDetail = '/pin/:id';
  static const String imageSearch = '/image-search';
  static const String searchResults = '/search-results';
  static const String settings = '/settings';
  static const String account = '/account';
}
