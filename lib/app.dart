import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/config/environment.dart';
import 'package:pinterest/core/theme/app_theme.dart';
import 'package:pinterest/core/ui/atoms/app_toast.dart';
import 'package:pinterest/core/utils/app_logger.dart';
import 'package:pinterest/features/localization/presentation/app_localizations.dart';
import 'package:pinterest/features/localization/presentation/providers/localization_providers.dart';
import 'package:pinterest/router/app_router.dart';

class PinterestApp extends ConsumerWidget {
  const PinterestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(appLocaleProvider);

    // Trigger localization initialization
    ref.watch(localizationProvider);

    return ClerkAuth(
      config: ClerkAuthConfig(
        publishableKey: Environment.clerkPublishableKey,
      ),
      child: ClerkErrorListener(
        handler: _handleClerkError,
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp.router(
              scaffoldMessengerKey: AppToast.rootMessengerKey,
              title: 'Pinterest',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.dark,
              locale: locale,
              supportedLocales: const [
                Locale('en'),
                Locale('hi'),
                Locale('te'),
              ],
              localizationsDelegates: [
                getAppLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }

  static void _handleClerkError(
    BuildContext context,
    clerk.ClerkError error,
  ) {
    AppLogger.error(
      '🔐 Clerk error: ${error.message}',
      error: error,
    );
  }
}
