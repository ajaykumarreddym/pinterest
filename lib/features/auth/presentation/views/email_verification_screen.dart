import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/features/auth/presentation/providers/auth_providers.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/ui/atoms/app_toast.dart';
import 'package:pinterest/core/utils/app_logger.dart';

/// Email verification screen shown after sign-up when Clerk requires
/// email code verification.
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  final String email;

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  final _codeController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          context.tr('auth.verifyYourEmail'),
          style: TextStyle(
            color: AppColors.textPrimaryDark,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
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

            // Description
            Text(
              context.tr('auth.verificationCodeSent'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 16.sp,
              ),
            ),

            SizedBox(height: 8.h),

            // Email address
            Text(
              widget.email,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 32.h),

            // Code input field
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
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 24.h),

            // Resend code
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.tr('auth.didntReceiveCode'),
                  style: TextStyle(
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
      ),
    );
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

      if (clerkAuth.isSignedIn && mounted) {
        // Complete auth in Riverpod
        final sessionToken = clerkAuth.session?.id ?? 'clerk_verified';
        await ref.read(authProvider.notifier).markAuthenticated(sessionToken);
        AppLogger.info('✅ Email verified and signed in');
        // Router redirect will handle navigation to home
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
      await clerkAuth.attemptSignUp(
        strategy: clerk.Strategy.emailCode,
      );

      if (mounted) {
        setState(() => _isResending = false);
        AppToast.info(
          context,
          message: 'Code resent to ${widget.email}',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isResending = false);
        AppToast.error(context, message: e.toString());
      }
    }
  }
}
