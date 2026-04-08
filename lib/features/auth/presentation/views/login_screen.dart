import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:pinterest/features/auth/presentation/providers/auth_providers.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';
import 'package:pinterest/core/constants/asset_constants.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/ui/atoms/app_toast.dart';
import 'package:pinterest/core/utils/validators/validators.dart';
import 'package:pinterest/features/auth/presentation/widgets/forgot_password_bottom_sheet.dart';
import 'package:pinterest/router/route_names.dart';

/// Pinterest login screen with email/password + Google sign-in.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimaryDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          context.tr('auth.logIn'),
          style: TextStyle(
            color: AppColors.textPrimaryDark,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Divider(color: AppColors.dividerDark, height: 1.h),

              SizedBox(height: 24.h),

              // Continue with Google button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await ref
                          .read(authProvider.notifier)
                          .loginWithGoogle(context);
                    } catch (e) {
                      if (mounted) {
                        AppToast.error(
                          context,
                          message: e.toString(),
                        );
                      }
                    }
                  },
                  icon: SvgPicture.asset(
                    AssetConstants.googleLogo,
                    width: 24.w,
                    height: 24.w,
                  ),
                  label: Text(
                    context.tr('auth.continueWithGoogle'),
                    style: TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.dividerDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              Text(
                context.tr('general.or'),
                style: TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 14.sp,
                ),
              ),

              SizedBox(height: 20.h),

              // Email field
              TextFormField(
                controller: _emailController,
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 16.sp,
                ),
                decoration: InputDecoration(
                  hintText: context.tr('auth.emailAddress'),
                  hintStyle: TextStyle(
                    color: AppColors.textTertiaryDark,
                    fontSize: 16.sp,
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Password field
              TextFormField(
                controller: _passwordController,
                validator: Validators.password,
                obscureText: _obscurePassword,
                style: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 16.sp,
                ),
                decoration: InputDecoration(
                  hintText: context.tr('auth.password'),
                  hintStyle: TextStyle(
                    color: AppColors.textTertiaryDark,
                    fontSize: 16.sp,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.iconDefault,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pinterestRed,
                    disabledBackgroundColor: AppColors.pinterestRedDark,
                  ),
                  child: Text(
                    context.tr('auth.logIn'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              if (_isLoading) ...[
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariantDark,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.pinterestRed,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        context.tr('general.loading'),
                        style: TextStyle(
                          color: AppColors.textSecondaryDark,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 16.h),

              TextButton(
                onPressed: () {
                  showForgotPasswordBottomSheet(
                    context,
                    prefillEmail: _emailController.text.trim().isNotEmpty
                        ? _emailController.text.trim()
                        : null,
                  );
                },
                child: Text(
                  context.tr('auth.forgottenPassword'),
                  style: TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              // Don't have an account → Sign up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.tr('auth.dontHaveAccount'),
                    style: TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 14.sp,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.goNamed(RouteNames.signUp),
                    child: Text(
                      context.tr('auth.signUp'),
                      style: TextStyle(
                        color: AppColors.textPrimaryDark,
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
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).login(
            context: context,
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      // Router redirect will handle navigation to home
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.error(context, message: e.toString());
      }
    }
  }
}
