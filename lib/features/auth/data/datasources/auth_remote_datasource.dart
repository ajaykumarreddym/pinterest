import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/widgets.dart';

import 'package:pinterest/features/auth/domain/entities/user.dart';

/// Remote data source for authentication via Clerk SDK.
abstract class AuthRemoteDatasource {
  Future<User> loginWithEmail({
    required BuildContext context,
    required String email,
    required String password,
  });

  Future<User> loginWithGoogle(BuildContext context);

  Future<void> logout(BuildContext context);

  User? getCurrentUser(BuildContext context);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  @override
  Future<User> loginWithEmail({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    final clerkAuth = ClerkAuth.of(context, listen: false);

    await clerkAuth.attemptSignIn(
      strategy: clerk.Strategy.password,
      identifier: email,
      password: password,
    );

    final clerkUser = clerkAuth.user;
    if (clerkUser == null) {
      throw Exception('Sign-in failed: no user returned');
    }

    return _mapClerkUser(clerkUser);
  }

  @override
  Future<User> loginWithGoogle(BuildContext context) async {
    final clerkAuth = ClerkAuth.of(context, listen: false);

    await clerkAuth.ssoSignIn(
      context,
      clerk.Strategy.oauthGoogle,
    );

    final clerkUser = clerkAuth.user;
    if (clerkUser == null) {
      throw Exception('Google sign-in failed: no user returned');
    }

    return _mapClerkUser(clerkUser);
  }

  @override
  Future<void> logout(BuildContext context) async {
    final clerkAuth = ClerkAuth.of(context, listen: false);
    await clerkAuth.signOut();
  }

  @override
  User? getCurrentUser(BuildContext context) {
    try {
      final clerkAuth = ClerkAuth.of(context, listen: false);
      final clerkUser = clerkAuth.user;
      if (clerkUser == null) return null;
      return _mapClerkUser(clerkUser);
    } catch (_) {
      return null;
    }
  }

  User _mapClerkUser(clerk.User clerkUser) {
    final primaryEmail = clerkUser.emailAddresses
        ?.where((e) => e.id == clerkUser.primaryEmailAddressId)
        .firstOrNull
        ?.emailAddress;

    return User(
      id: clerkUser.id,
      email: primaryEmail ?? '',
      displayName: [clerkUser.firstName, clerkUser.lastName]
          .where((s) => s != null && s.isNotEmpty)
          .join(' '),
      avatarUrl: clerkUser.imageUrl,
    );
  }
}
