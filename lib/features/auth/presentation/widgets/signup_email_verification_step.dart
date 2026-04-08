import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/core/ui/atoms/app_toast.dart';
import 'package:pinterest/core/utils/app_logger.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';

/// Signup step — Email verification code entry.
///
/// Shown after account creation when Clerk requires email verification.
/// Accepts the 6-digit code sent to [email] and calls [onVerified] with the
/// Clerk session token on success.
class SignupEmailVerificationStep extends StatefulWidget {
  const SignupEmailVerificationStep({
    super.key,
    required this.email,
    required this.onVerified,
  });

  final String email;
  final ValueChanged<String> onVerified;

  @override
  State<SignupEmailVerificationStep> createState() =>
      _SignupEmailVerificationStepState();
}

class _SignupEmailVerificationStepState
    extends State<SignupEmailVerificationStep> {
  final _codeController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final code = _codeController.text.trim();
    if (code.length != 6) return;

    setState(() => _isVerifying = true);

    try {
      final clerkAuth = ClerkAuth.of(context, listen: false);

      await clerkAuth.attemptSignUp(
        strategy: clerk.Strategy.emailCode,
        code: code,
      );

      if (!mounted) return;

      if (clerkAuth.isSignedIn) {
        final sessionToken = clerkAuth.session?.id ?? 'clerk_verified';
        AppLogger.info('✅ Email verified during signup');
        widget.onVerified(sessionToken);
      } else {
        setState(() => _isVerifying = false);
        AppToast.error(
          context,
          message: context.tr('auth.verificationFailed'),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isVerifying = false);
        AppToast.error(context, message: e.toString());
      }
    }
  }

  Future<void> _handleResend() async {
    setState(() => _isResending = true);

    try {
      final clerkAuth = ClerkAuth.of(context, listen: false);
      await clerkAuth.attemptSignUp(strategy: clerk.Strategy.emailCode);

      if (mounted) {
        setState(() => _isResending = false);
        AppToast.success(
          context,
          message: context.tr('auth.verificationCodeResent'),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isResending = false);
        AppToast.error(context, message: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          SizedBox(height: 40.h),

          // Email icon
          Icon(
            Icons.mark_email_read_outlined,
            color: AppColors.pinterestRed,
            size: 64.sp,
          ),

          SizedBox(height: 24.h),

          // Title
          Text(
            context.tr('auth.verifyYourEmail'),
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimaryDark,
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 12.h),

          // Description
          Text(
            context.tr('auth.verificationCodeSent'),
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
              fontSize: 14.sp,
            ),
          ),

          SizedBox(height: 4.h),

          // Email address
          Text(
            widget.email,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimaryDark,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 32.h),

          // Code input
          TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              color: AppColors.textPrimaryDark,
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 8.w,
            ),
            decoration: InputDecoration(
              hintText: context.tr('auth.enterCode'),
              hintStyle: TextStyle(
                color: AppColors.textTertiaryDark,
                fontSize: 16.sp,
                fontWeight: FontWeight.normal,
                letterSpacing: 0,
              ),
              counterText: '',
            ),
          ),

          SizedBox(height: 24.h),

          // Verify button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: _isVerifying ? null : _handleVerify,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pinterestRed,
                disabledBackgroundColor: AppColors.pinterestRedDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: _isVerifying
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      context.tr('auth.verify'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          SizedBox(height: 16.h),

          // Resend code
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.tr('auth.didntReceiveCode'),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondaryDark,
                  fontSize: 14.sp,
                ),
              ),
              TextButton(
                onPressed: _isResending ? null : _handleResend,
                child: _isResending
                    ? SizedBox(
                        width: 14.w,
                        height: 14.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.pinterestRed,
                        ),
                      )
                    : Text(
                        context.tr('auth.resendCode'),
                        style: TextStyle(
                          color: AppColors.pinterestRed,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
