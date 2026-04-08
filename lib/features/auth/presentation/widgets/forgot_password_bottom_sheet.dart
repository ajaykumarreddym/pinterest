import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/core/ui/atoms/app_text_field.dart';
import 'package:pinterest/core/ui/atoms/app_toast.dart';
import 'package:pinterest/core/utils/validators/validators.dart';
import 'package:pinterest/features/auth/presentation/providers/auth_providers.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';

/// Shows the forgot-password bottom sheet with a 3-step flow:
/// 1. Enter email → sends reset code
/// 2. Enter code + new password → resets password
/// 3. Auto-signs in on success
Future<void> showForgotPasswordBottomSheet(
  BuildContext context, {
  String? prefillEmail,
}) async {
  final screenHeight = MediaQuery.sizeOf(context).height;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundDark,
    barrierColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: AppBorders.bottomSheet),
    builder: (_) => SizedBox(
      height: screenHeight * 0.94,
      child: _ForgotPasswordContent(prefillEmail: prefillEmail),
    ),
  );
}

class _ForgotPasswordContent extends ConsumerStatefulWidget {
  const _ForgotPasswordContent({this.prefillEmail});

  final String? prefillEmail;

  @override
  ConsumerState<_ForgotPasswordContent> createState() =>
      _ForgotPasswordContentState();
}

class _ForgotPasswordContentState
    extends ConsumerState<_ForgotPasswordContent> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _codeSent = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.prefillEmail != null && widget.prefillEmail!.isNotEmpty) {
      _emailController.text = widget.prefillEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  bool get _isEmailValid =>
      Validators.email(_emailController.text.trim()) == null &&
      _emailController.text.trim().isNotEmpty;

  bool get _isResetFormValid =>
      _codeController.text.trim().length == 6 &&
      Validators.password(_newPasswordController.text) == null &&
      _newPasswordController.text.isNotEmpty;

  Future<void> _handleSendResetCode() async {
    if (!_isEmailValid) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).initiatePasswordReset(
            context: context,
            email: _emailController.text.trim(),
          );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _codeSent = true;
        });
        AppToast.success(
          context,
          message: context.tr('auth.resetCodeSent'),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.error(context, message: e.toString());
      }
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_isResetFormValid) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).resetPassword(
            context: context,
            code: _codeController.text.trim(),
            newPassword: _newPasswordController.text,
          );

      if (mounted) {
        AppToast.success(
          null,
          message: context.tr('auth.passwordResetSuccess'),
        );
        // Close both forgot-password and login sheets.
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.error(context, message: e.toString());
      }
    }
  }

  Future<void> _handleResendCode() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).initiatePasswordReset(
            context: context,
            email: _emailController.text.trim(),
          );

      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.success(
          context,
          message: context.tr('auth.resetCodeSent'),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.error(context, message: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              _buildHeader(context),
              SizedBox(height: 24.h),

              // Icon
              Icon(
                _codeSent ? Icons.lock_reset_rounded : Icons.lock_outlined,
                color: AppColors.pinterestRed,
                size: 56.sp,
              ),
              SizedBox(height: 20.h),

              if (!_codeSent) ...[
                _buildEmailStep(context),
              ] else ...[
                _buildCodeAndPasswordStep(context),
              ],

              SizedBox(
                height: MediaQuery.paddingOf(context).bottom + 24.h,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(
              _codeSent ? Icons.arrow_back_ios_new_rounded : Icons.close,
              color: AppColors.textPrimaryDark,
              size: _codeSent ? 20.w : 24.w,
            ),
          ),
        ),
        Text(
          context.tr('auth.resetPassword'),
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailStep(BuildContext context) {
    return Column(
      children: [
        // Description
        Text(
          context.tr('auth.resetPasswordDescription'),
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondaryDark,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 24.h),

        // Email field
        AppTextField(
          controller: _emailController,
          label: context.tr('auth.email'),
          hint: context.tr('auth.enterYourEmail'),
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 24.h),

        // Send code button
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: _isEmailValid && !_isLoading
                ? _handleSendResetCode
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pinterestRed,
              disabledBackgroundColor: const Color(0xFF5F5F5F),
              disabledForegroundColor: const Color(0xFF9B9B9B),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    context.tr('auth.sendResetCode'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeAndPasswordStep(BuildContext context) {
    return Column(
      children: [
        // Email display
        Text(
          context.tr('auth.enterResetCode'),
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondaryDark,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          _emailController.text.trim(),
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimaryDark,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 24.h),

        // Code input
        TextFormField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() {}),
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
        SizedBox(height: 16.h),

        // Resend code
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.tr('auth.didntReceiveCode'),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondaryDark,
                fontSize: 13.sp,
              ),
            ),
            TextButton(
              onPressed: _isLoading ? null : _handleResendCode,
              child: Text(
                context.tr('auth.resendCode'),
                style: TextStyle(
                  color: AppColors.pinterestRed,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // New password field
        AppTextField(
          controller: _newPasswordController,
          label: context.tr('auth.newPassword'),
          hint: context.tr('auth.enterNewPassword'),
          obscureText: _obscurePassword,
          validator: Validators.password,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (_) => setState(() {}),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textPrimaryDark,
              size: 20.w,
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
        ),
        SizedBox(height: 24.h),

        // Reset password button
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: _isResetFormValid && !_isLoading
                ? _handleResetPassword
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pinterestRed,
              disabledBackgroundColor: const Color(0xFF5F5F5F),
              disabledForegroundColor: const Color(0xFF9B9B9B),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    context.tr('auth.resetPassword'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
