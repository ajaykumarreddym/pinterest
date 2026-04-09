import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:pinterest/core/constants/asset_constants.dart';
import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/core/ui/atoms/app_social_button.dart';
import 'package:pinterest/core/ui/atoms/app_text_field.dart';
import 'package:pinterest/core/ui/atoms/app_toast.dart';
import 'package:pinterest/core/utils/validators/validators.dart';
import 'package:pinterest/features/auth/presentation/providers/auth_providers.dart';
import 'package:pinterest/features/auth/presentation/widgets/forgot_password_bottom_sheet.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';

/// Shows the Pinterest-style login bottom sheet covering ~97% of the screen.
///
/// If [prefillEmail] is provided, the email field is pre-populated.
/// Returns a [Future] that completes when the sheet is dismissed.
Future<void> showLoginBottomSheet(
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
      child: _LoginBottomSheetContent(prefillEmail: prefillEmail),
    ),
  );
}

class _LoginBottomSheetContent extends ConsumerStatefulWidget {
  const _LoginBottomSheetContent({this.prefillEmail});

  final String? prefillEmail;

  @override
  ConsumerState<_LoginBottomSheetContent> createState() =>
      _LoginBottomSheetContentState();
}

class _LoginBottomSheetContentState
    extends ConsumerState<_LoginBottomSheetContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefillEmail != null && widget.prefillEmail!.isNotEmpty) {
      _emailController.text = widget.prefillEmail!;
    }
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final emailOk = Validators.email(_emailController.text.trim()) == null;
    final passOk = Validators.password(_passwordController.text) == null;
    final valid = emailOk && passOk;
    if (valid != _isFormValid) {
      setState(() => _isFormValid = valid);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_isFormValid) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      await ref.read(authProvider.notifier).login(
            context: context,
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    } catch (e) {
      if (mounted) {
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12.h),

                // ── Header: Close + Title ──
                _buildHeader(context),
                SizedBox(height: 24.h),

                // ── Continue with Google ──
                AppSocialButton(
                  label: context.tr('auth.continueWithGoogle'),
                  icon: SvgPicture.asset(
                    AssetConstants.googleLogo,
                    width: 20.w,
                    height: 20.w,
                  ),
                  onPressed: () async {
                    await ref
                        .read(authProvider.notifier)
                        .loginWithGoogle(context);
                  },
                ),
                SizedBox(height: 12.h),

                // ── Continue with Apple ──
               /*  AppSocialButton(
                  label: context.tr('auth.continueWithApple'),
                  icon: Icon(
                    Icons.apple,
                    color: AppColors.textPrimaryDark,
                    size: 22.w,
                  ),
                  onPressed: () {
                    // Apple sign-in — to be implemented later
                  },
                ), */
                SizedBox(height: 20.h),

                // ── OR divider ──
                Text(
                  context.tr('general.or').toUpperCase(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20.h),

                // ── Email field ──
                AppTextField(
                  controller: _emailController,
                  label: context.tr('auth.email'),
                  hint: context.tr('auth.enterYourEmail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                SizedBox(height: 16.h),

                // ── Password field ──
                AppTextField(
                  controller: _passwordController,
                  label: context.tr('auth.password'),
                  hint: context.tr('auth.enterYourPassword'),
                  obscureText: _obscurePassword,
                  validator: Validators.password,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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

                // ── Log in button ──
                _buildLoginButton(context),
                SizedBox(height: 24.h),

                // ── Forgotten password ──
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(); // close login sheet
                    showForgotPasswordBottomSheet(
                      context,
                      prefillEmail: _emailController.text.trim().isNotEmpty
                          ? _emailController.text.trim()
                          : null,
                    );
                  },
                  child: Text(
                    context.tr('auth.forgottenPassword'),
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.paddingOf(context).bottom + 24.h,
                ),
              ],
            ),
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
              Icons.close,
              color: AppColors.textPrimaryDark,
              size: 24.w,
            ),
          ),
        ),
        Text(
          context.tr('auth.logIn'),
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: _isFormValid ? _handleLogin : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pinterestRed,
          disabledBackgroundColor: const Color(0xFF5F5F5F),
          disabledForegroundColor: const Color(0xFF9B9B9B),
          foregroundColor: AppColors.textPrimaryDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
        ),
        child: Text(
          context.tr('auth.logIn'),
          style: AppTypography.labelLarge.copyWith(
            fontSize: 16.sp,
            color: _isFormValid
                ? AppColors.textPrimaryDark
                : const Color(0xFF9B9B9B),
          ),
        ),
      ),
    );
  }
}

