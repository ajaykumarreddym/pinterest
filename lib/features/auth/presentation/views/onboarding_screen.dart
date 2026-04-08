import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pinterest/core/constants/asset_constants.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/dimensions/app_dimensions.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/core/ui/atoms/app_button.dart';
import 'package:pinterest/features/auth/presentation/widgets/login_bottom_sheet.dart';
import 'package:pinterest/features/auth/presentation/widgets/welcome_collage.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';
import 'package:pinterest/router/route_names.dart';

/// Pinterest welcome / landing screen.
///
/// Displays a photo collage background, the Pinterest logo,
/// "Create a life you love" tagline, and Sign up / Log in buttons.
///
/// When the login bottom sheet opens the content scales down slightly,
/// revealing a black background with rounded corners (Pinterest style).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sheetAnimController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _radiusAnimation;

  @override
  void initState() {
    super.initState();
    _sheetAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _sheetAnimController, curve: Curves.easeOut),
    );
    _radiusAnimation = Tween<double>(begin: 0.0, end: 16.0).animate(
      CurvedAnimation(parent: _sheetAnimController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _sheetAnimController.dispose();
    super.dispose();
  }

  Future<void> _openLoginSheet() async {
    _sheetAnimController.forward();
    await showLoginBottomSheet(context);
    _sheetAnimController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final buttonPadding = EdgeInsets.symmetric(
      horizontal: AppDimensions.authButtonHorizontalMargin,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _sheetAnimController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                _radiusAnimation.value.r,
              ),
              child: child,
            ),
          );
        },
        child: ColoredBox(
          color: AppColors.backgroundDark,
          child: Column(
            children: [
              // ── Photo collage (fills available top space) ──
              const Expanded(child: WelcomeCollage()),

              SizedBox(height: 14.h),

              // ── Pinterest logo ──
              SvgPicture.asset(
                AssetConstants.pinterestLogo,
                width: 44.w,
                height: 44.w,
              ),
              SizedBox(height: 12.h),

              // ── Tagline ──
              Text(
                context.tr('auth.onboardingTagline'),
                textAlign: TextAlign.center,
                style: AppTypography.h1.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontSize: 26.sp,
                ),
              ),
              SizedBox(height: 24.h),

              // ── Sign up button (Pinterest Red) ──
              Padding(
                padding: buttonPadding,
                child: AppButton(
                  label: context.tr('auth.signUp'),
                  onPressed: () => context.pushNamed(RouteNames.signUp),
                  backgroundColor: AppColors.pinterestRed,
                  foregroundColor: AppColors.textPrimaryDark,
                ),
              ),
              SizedBox(height: 8.h),

              // ── Log in button (dark gray) ──
              Padding(
                padding: buttonPadding,
                child: AppButton(
                  label: context.tr('auth.logIn'),
                  onPressed: _openLoginSheet,
                  backgroundColor: const Color(0xFF3A3A3A),
                  foregroundColor: AppColors.textPrimaryDark,
                ),
              ),
              SizedBox(height: 10.h),

              // ── Terms of Service text ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: _TermsText(),
              ),
              SizedBox(height: MediaQuery.paddingOf(context).bottom + 6.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      color: AppColors.textPrimaryDark,
      fontSize: 10.sp,
      height: 1.4,
    );
    final linkStyle = baseStyle.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: AppColors.textPrimaryDark,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: "By continuing, you agree to Pinterest's ",
            style: baseStyle,
          ),
          TextSpan(text: 'Terms of Service', style: linkStyle),
          TextSpan(text: ' and acknowledge\n ', style: baseStyle),
          TextSpan(text: "you've read our ", style: baseStyle),
          TextSpan(text: 'Privacy Policy', style: linkStyle),
          TextSpan(text: '. ', style: baseStyle),
          TextSpan(text: 'Notice at Collection', style: linkStyle),
          TextSpan(text: '.', style: baseStyle),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
