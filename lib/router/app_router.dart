import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pinterest/features/auth/presentation/providers/auth_providers.dart';
import 'package:pinterest/features/auth/presentation/views/onboarding_screen.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/auth/presentation/views/login_screen.dart';
import 'package:pinterest/features/auth/presentation/views/signup_screen.dart';
import 'package:pinterest/features/auth/presentation/views/email_verification_screen.dart';
import 'package:pinterest/features/auth/presentation/views/clerk_auth_screen.dart';
import 'package:pinterest/features/home/presentation/views/home_screen.dart';
import 'package:pinterest/features/search/presentation/views/search_screen.dart';
import 'package:pinterest/features/create/presentation/views/create_screen.dart';
import 'package:pinterest/features/messages/presentation/views/messages_screen.dart';
import 'package:pinterest/features/messages/presentation/views/chat_detail_screen.dart';
import 'package:pinterest/features/messages/domain/entities/conversation.dart';
import 'package:pinterest/features/profile/presentation/views/profile_screen.dart';
import 'package:pinterest/features/pin_detail/presentation/views/pin_detail_screen.dart';
import 'package:pinterest/features/search/presentation/views/image_search_screen.dart';
import 'package:pinterest/features/search/presentation/views/search_results_screen.dart';
import 'package:pinterest/features/search/presentation/views/video_detail_screen.dart';
import 'package:pinterest/features/search/domain/entities/search_video.dart';
import 'package:pinterest/features/settings/presentation/views/account_screen.dart';
import 'package:pinterest/features/settings/presentation/views/refine_recommendations_screen.dart';
import 'package:pinterest/router/route_names.dart';
import 'package:pinterest/router/shell_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authStatus = ref.watch(authProvider);
  final hasTopics = ref.watch(hasSelectedTopicsProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.onboarding,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuth = authStatus == AuthStatus.authenticated;
      final isOnAuthPage = state.matchedLocation == RoutePaths.onboarding ||
          state.matchedLocation == RoutePaths.login ||
          state.matchedLocation == RoutePaths.signUp ||
          state.matchedLocation == RoutePaths.emailVerification ||
          state.matchedLocation == RoutePaths.clerkAuth;
      final isOnPicksPage =
          state.matchedLocation == RoutePaths.refineRecommendations;

      // Not authenticated → redirect from protected pages to onboarding
      if (!isAuth && !isOnAuthPage) return RoutePaths.onboarding;

      if (isAuth) {
        // No topics selected → send to refine recommendations
        if (!hasTopics) {
          if (!isOnPicksPage) return RoutePaths.refineRecommendations;
          return null;
        }

        // Has topics → redirect away from auth / picks pages to home
        if (isOnAuthPage || isOnPicksPage) return RoutePaths.home;
      }

      return null; // no redirect needed
    },
    routes: [
      // Auth routes
      GoRoute(
        name: RouteNames.onboarding,
        path: RoutePaths.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        name: RouteNames.login,
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: RouteNames.signUp,
        path: RoutePaths.signUp,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          return SignUpScreen(prefillEmail: email);
        },
      ),
      GoRoute(
        name: RouteNames.emailVerification,
        path: RoutePaths.emailVerification,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return EmailVerificationScreen(email: email);
        },
      ),
      GoRoute(
        name: RouteNames.clerkAuth,
        path: RoutePaths.clerkAuth,
        builder: (context, state) => const ClerkAuthScreen(),
      ),

      // Post-login topic picks
      GoRoute(
        name: RouteNames.refineRecommendations,
        path: RoutePaths.refineRecommendations,
        builder: (context, state) =>
            const RefineRecommendationsScreen(isPostLogin: true),
      ),

      // Main shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ShellScaffold(child: child);
        },
        routes: [
          GoRoute(
            name: RouteNames.home,
            path: RoutePaths.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            name: RouteNames.search,
            path: RoutePaths.search,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SearchScreen(),
            ),
          ),
          GoRoute(
            name: RouteNames.create,
            path: RoutePaths.create,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CreateScreen(),
            ),
          ),
          GoRoute(
            name: RouteNames.messages,
            path: RoutePaths.messages,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MessagesScreen(),
            ),
          ),
          GoRoute(
            name: RouteNames.profile,
            path: RoutePaths.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // Pin detail (pushes over shell)
      GoRoute(
        name: RouteNames.pinDetail,
        path: RoutePaths.pinDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final pinId = state.pathParameters['id'] ?? '';
          return PinDetailScreen(pinId: pinId);
        },
      ),

      // Image search (visual search results)
      GoRoute(
        name: RouteNames.imageSearch,
        path: RoutePaths.imageSearch,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final photo = state.extra! as Photo;
          return ImageSearchScreen(photo: photo);
        },
      ),

      // Video detail (pushes over shell)
      GoRoute(
        name: RouteNames.videoDetail,
        path: RoutePaths.videoDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final video = state.extra! as SearchVideo;
          return VideoDetailScreen(video: video);
        },
      ),

      // Search results (pushed from search home)
      GoRoute(
        name: RouteNames.searchResults,
        path: RoutePaths.searchResults,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final query = state.uri.queryParameters['q'] ?? '';
          return SearchResultsScreen(initialQuery: query);
        },
      ),

      // Account / Settings
      GoRoute(
        name: RouteNames.account,
        path: RoutePaths.account,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AccountScreen(),
      ),

      // Chat detail (pushes over shell)
      GoRoute(
        name: RouteNames.chatDetail,
        path: RoutePaths.chatDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final conversation = state.extra! as Conversation;
          return ChatDetailScreen(conversation: conversation);
        },
      ),
    ],
  );
});
