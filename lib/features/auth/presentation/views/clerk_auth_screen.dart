import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/features/auth/presentation/providers/auth_providers.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/utils/app_logger.dart';

/// Wrapper screen that shows Clerk's pre-built authentication UI.
class ClerkAuthScreen extends ConsumerStatefulWidget {
  const ClerkAuthScreen({super.key});

  @override
  ConsumerState<ClerkAuthScreen> createState() => _ClerkAuthScreenState();
}

class _ClerkAuthScreenState extends ConsumerState<ClerkAuthScreen> {
  @override
  Widget build(BuildContext context) {
    final clerkAuth = ClerkAuth.of(context);

    // Listen for sign-in completion and sync with Riverpod
    if (clerkAuth.isSignedIn) {
      _syncAuthState(clerkAuth);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimaryDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: const ClerkAuthentication(),
      ),
    );
  }

  void _syncAuthState(ClerkAuthState clerkAuth) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(authProvider.notifier);
      if (ref.read(authProvider) != AuthStatus.authenticated) {
        final sessionToken = clerkAuth.session?.id ?? 'clerk_auth_widget';
        await notifier.markAuthenticated(sessionToken);
        AppLogger.info('✅ Clerk auth widget → authenticated');
      }
    });
  }
}
