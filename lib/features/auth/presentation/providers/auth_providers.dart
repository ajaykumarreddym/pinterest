import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/core/di/injection.dart';
import 'package:pinterest/core/utils/app_logger.dart';
import 'package:pinterest/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:pinterest/features/auth/data/datasources/user_profile_datasource.dart';
import 'package:pinterest/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pinterest/features/auth/domain/repositories/auth_repository.dart';

// ─── Datasources ────────────────────────────────────────────────

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  return AuthLocalDatasourceImpl(storage: ref.read(appStorageProvider));
});

final userProfileDatasourceProvider = Provider<UserProfileDatasource>((ref) {
  return UserProfileDatasourceImpl(storage: ref.read(appStorageProvider));
});

// ─── Repository ─────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    localDatasource: ref.read(authLocalDatasourceProvider),
  );
});

// ─── Auth State ─────────────────────────────────────────────────

/// Tracks the overall authentication state used by the router guard.
enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthNotifier extends Notifier<AuthStatus> {
  @override
  AuthStatus build() {
    final local = ref.read(authLocalDatasourceProvider);
    final token = local.getAuthToken();
    final onboarded = local.isOnboardingComplete();

    AppLogger.info(
      '🔐 AuthNotifier.build — token: ${token != null}, onboarded: $onboarded',
    );

    if (token != null && token.isNotEmpty) return AuthStatus.authenticated;
    return AuthStatus.unauthenticated;
  }

  /// Whether the user has finished the onboarding screen.
  bool get isOnboardingComplete {
    final local = ref.read(authLocalDatasourceProvider);
    return local.isOnboardingComplete();
  }

  /// Update auth state from external callers (e.g. ClerkAuthentication widget,
  /// email verification screen).
  Future<void> markAuthenticated(String sessionToken) async {
    final local = ref.read(authLocalDatasourceProvider);
    await local.cacheAuthToken(sessionToken);
    await local.setOnboardingComplete();
    state = AuthStatus.authenticated;
    AppLogger.info('✅ Auth state marked authenticated');
  }

  /// Called after successful Clerk email/password sign-in.
  /// [context] is required to access ClerkAuthState from the widget tree.
  Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    final clerkAuth = ClerkAuth.of(context, listen: false);

    // Clear any stale sign-in state.
    try {
      await clerkAuth.resetClient();
    } catch (_) {}

    // Step 1: Identify the user (creates sign-in object).
    try {
      await clerkAuth.attemptSignIn(
        strategy: clerk.Strategy.emailAddress,
        identifier: email,
      );
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('not found') ||
          msg.contains("couldn't find") ||
          msg.contains('no account')) {
        throw Exception('Account not found. Please sign up first.');
      }
      rethrow;
    }

    if (clerkAuth.signIn == null && clerkAuth.client.user == null) {
      throw Exception('Account not found. Please sign up first.');
    }

    // Already signed in after identification (e.g. single-factor email-only).
    if (clerkAuth.isSignedIn) {
      await _completeLogin(clerkAuth);
      return;
    }

    AppLogger.info(
      '🔐 SignIn created, status: ${clerkAuth.signIn?.status}',
    );

    // Step 2: Verify password (sends password as first factor).
    await clerkAuth.attemptSignIn(
      strategy: clerk.Strategy.password,
      password: password,
    );

    AppLogger.info(
      '🔐 After password — isSignedIn: ${clerkAuth.isSignedIn}, '
      'signIn status: ${clerkAuth.signIn?.status}, '
      'session: ${clerkAuth.session?.id}',
    );

    if (clerkAuth.isSignedIn || clerkAuth.client.user != null) {
      await _completeLogin(clerkAuth);
      return;
    }

    // If sign-in needs second factor (2FA), we treat password as valid
    // and complete login since this clone doesn't implement 2FA UI.
    if (clerkAuth.signIn?.status == clerk.Status.needsSecondFactor) {
      AppLogger.info('🔐 2FA required — bypassing, password was correct');
      final sessionId = clerkAuth.signIn?.createdSessionId;
      final token = sessionId ?? 'clerk_login_${DateTime.now().millisecondsSinceEpoch}';
      await _completeLoginWithToken(token);
      return;
    }

    // Check if a session was created even though isSignedIn is false.
    if (clerkAuth.session != null) {
      await _completeLogin(clerkAuth);
      return;
    }

    throw Exception('Invalid email or password. Please try again.');
  }

  /// Completes login by caching Clerk session and updating auth state.
  Future<void> _completeLogin(ClerkAuthState clerkAuth) async {
    final sessionToken = clerkAuth.session?.id ?? 'clerk_session';
    await _completeLoginWithToken(sessionToken);
    AppLogger.info('✅ User signed in via Clerk (email/password)');
  }

  Future<void> _completeLoginWithToken(String token) async {
    final local = ref.read(authLocalDatasourceProvider);
    await local.cacheAuthToken(token);
    await local.setOnboardingComplete();
    state = AuthStatus.authenticated;
  }

  /// Initiates a password reset flow via Clerk.
  ///
  /// Sends a reset code to the user's email. After calling this,
  /// the user must enter the code + new password via [resetPassword].
  Future<void> initiatePasswordReset({
    required BuildContext context,
    required String email,
  }) async {
    final clerkAuth = ClerkAuth.of(context, listen: false);

    try {
      await clerkAuth.resetClient();
    } catch (_) {}

    await clerkAuth.initiatePasswordReset(
      identifier: email,
      strategy: clerk.Strategy.resetPasswordEmailCode,
    );

    AppLogger.info('📧 Password reset code sent to $email');
  }

  /// Completes the password reset flow.
  ///
  /// Verifies the [code] from the reset email and sets the [newPassword].
  Future<void> resetPassword({
    required BuildContext context,
    required String code,
    required String newPassword,
  }) async {
    final clerkAuth = ClerkAuth.of(context, listen: false);

    await clerkAuth.attemptSignIn(
      strategy: clerk.Strategy.resetPasswordEmailCode,
      code: code,
      password: newPassword,
    );

    AppLogger.info(
      '🔐 Reset password — isSignedIn: ${clerkAuth.isSignedIn}, '
      'signIn status: ${clerkAuth.signIn?.status}',
    );

    if (clerkAuth.isSignedIn || clerkAuth.client.user != null) {
      await _completeLogin(clerkAuth);
    }
  }

  /// Check if an email is already registered in Clerk.
  ///
  /// Uses [Strategy.emailAddress] to start an identification-only sign-in.
  /// Clerk routes "not found" errors through [ClerkErrorListener] rather
  /// than throwing, so we check [signIn] state after the call.
  ///
  /// Calls [resetClient] before and after to avoid stale sign-in state.
  Future<bool> isEmailRegistered({
    required BuildContext context,
    required String email,
  }) async {
    final clerkAuth = ClerkAuth.of(context, listen: false);

    // Clear any stale sign-in / sign-up state from previous attempts.
    try {
      await clerkAuth.resetClient();
    } catch (_) {}

    try {
      await clerkAuth.attemptSignIn(
        strategy: clerk.Strategy.emailAddress,
        identifier: email,
      );
    } catch (_) {
      // Errors may or may not be thrown — either way, check state below.
    }

    // If Clerk created a sign-in object, the email exists.
    final exists = clerkAuth.signIn != null;

    if (exists) {
      AppLogger.info('📧 Email check: $email IS registered in Clerk');
      // Clean up so the sign-in state doesn't interfere with later flows.
      try {
        await clerkAuth.resetClient();
      } catch (_) {}
    } else {
      AppLogger.info('📧 Email check: $email is NOT registered');
    }

    return exists;
  }

  /// Creates a Clerk account **without** changing [AuthStatus].
  ///
  /// Call this at the password step of sign-up. Creates the account with
  /// email + password, then sends a verification code if Clerk requires it.
  ///
  /// Returns a [CreateAccountResult] with the session token and whether
  /// email verification is required.
  Future<CreateAccountResult> createAccount({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    final clerkAuth = ClerkAuth.of(context, listen: false);

    await clerkAuth.attemptSignUp(
      strategy: clerk.Strategy.password,
      emailAddress: email,
      password: password,
      passwordConfirmation: password,
    );

    if (clerkAuth.isSignedIn) {
      final token = clerkAuth.session?.id ?? 'clerk_signup_session';
      AppLogger.info('✅ Clerk account created & signed in (no verification needed)');
      return CreateAccountResult(token: token, needsVerification: false);
    }

    // Send verification email if required
    final signUp = clerkAuth.client.signUp;
    if (signUp != null &&
        signUp.unverifiedFields.contains(clerk.Field.emailAddress)) {
      await clerkAuth.attemptSignUp(strategy: clerk.Strategy.emailCode);
      AppLogger.info('📧 Verification code sent to $email');
      return CreateAccountResult(
        token: 'signup_pending_${DateTime.now().millisecondsSinceEpoch}',
        needsVerification: true,
      );
    }

    return CreateAccountResult(
      token: 'signup_pending_${DateTime.now().millisecondsSinceEpoch}',
      needsVerification: false,
    );
  }

  /// Full sign-up: creates account and marks authenticated immediately.
  Future<void> signUp({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    final result = await createAccount(
      context: context,
      email: email,
      password: password,
    );
    await markAuthenticated(result.token);
  }

  /// Called after Google SSO sign-in.
  /// [context] is required for ClerkAuthState SSO WebView overlay.
  Future<void> loginWithGoogle(BuildContext context) async {
    final clerkAuth = ClerkAuth.of(context, listen: false);

    await clerkAuth.ssoSignIn(
      context,
      clerk.Strategy.oauthGoogle,
    );

    if (clerkAuth.isSignedIn) {
      final local = ref.read(authLocalDatasourceProvider);
      final sessionToken = clerkAuth.session?.id ?? 'clerk_google_session';
      await local.cacheAuthToken(sessionToken);
      await local.setOnboardingComplete();
      state = AuthStatus.authenticated;
      AppLogger.info('✅ User signed in via Clerk (Google SSO)');
    } else {
      AppLogger.info('⚠️ Google SSO flow cancelled or did not complete');
    }
  }

  /// Skip auth (continue as guest from onboarding).
  Future<void> continueAsGuest() async {
    final local = ref.read(authLocalDatasourceProvider);
    await local.setOnboardingComplete();
    await local.cacheAuthToken('guest_${DateTime.now().millisecondsSinceEpoch}');
    state = AuthStatus.authenticated;
    AppLogger.info('✅ Continuing as guest');
  }

  /// Sync Riverpod state with Clerk's auth state.
  /// Call this when the app resumes or ClerkAuthState notifies a change.
  void syncWithClerk(BuildContext context) {
    try {
      final clerkAuth = ClerkAuth.of(context, listen: false);
      if (clerkAuth.isSignedIn && state != AuthStatus.authenticated) {
        final local = ref.read(authLocalDatasourceProvider);
        final sessionToken = clerkAuth.session?.id ?? 'clerk_synced';
        local.cacheAuthToken(sessionToken);
        local.setOnboardingComplete();
        state = AuthStatus.authenticated;
        AppLogger.info('🔄 Synced: Clerk signed in → authenticated');
      } else if (!clerkAuth.isSignedIn && state == AuthStatus.authenticated) {
        // Check if it's a guest session — don't sign out guests
        final local = ref.read(authLocalDatasourceProvider);
        final token = local.getAuthToken();
        if (token != null && !token.startsWith('guest_')) {
          local.clearAuth();
          state = AuthStatus.unauthenticated;
          AppLogger.info('🔄 Synced: Clerk signed out → unauthenticated');
        }
      }
    } catch (_) {
      // ClerkAuth not yet available in tree
    }
  }

  /// Log out from both Clerk and local storage.
  Future<void> logout({BuildContext? context}) async {
    if (context != null) {
      try {
        final clerkAuth = ClerkAuth.of(context, listen: false);
        if (clerkAuth.isSignedIn) {
          await clerkAuth.signOut();
          AppLogger.info('🚪 Clerk signed out');
        }
      } catch (_) {
        // ClerkAuth not available — just clear local
      }
    }

    final local = ref.read(authLocalDatasourceProvider);
    await local.clearAuth();
    state = AuthStatus.unauthenticated;
    AppLogger.info('🚪 User logged out');
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthStatus>(
  AuthNotifier.new,
);

/// Result of [AuthNotifier.createAccount].
class CreateAccountResult {
  const CreateAccountResult({
    required this.token,
    required this.needsVerification,
  });

  final String token;
  final bool needsVerification;
}
