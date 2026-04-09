import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/core/ui/atoms/app_button.dart';
import 'package:pinterest/core/ui/atoms/app_text_field.dart';
import 'package:pinterest/core/ui/atoms/app_toast.dart';
import 'package:pinterest/core/utils/validators/validators.dart';
import 'package:pinterest/features/auth/presentation/providers/auth_providers.dart';
import 'package:pinterest/features/auth/presentation/widgets/login_bottom_sheet.dart';
import 'package:pinterest/features/auth/presentation/widgets/signup_birthday_step.dart';
import 'package:pinterest/features/auth/presentation/widgets/signup_confirmation_step.dart';
import 'package:pinterest/features/auth/presentation/widgets/signup_country_step.dart';
import 'package:pinterest/features/auth/presentation/widgets/signup_email_verification_step.dart';
import 'package:pinterest/features/auth/presentation/widgets/signup_gender_step.dart';
import 'package:pinterest/features/auth/presentation/widgets/signup_topics_step.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';
import 'package:pinterest/features/auth/domain/entities/user_profile.dart';

/// Total number of signup steps shown in the dot indicator.
const _kTotalSteps = 8;

/// Pinterest-style multi-step sign-up screen.
///
/// Step 0: Email input
/// Step 1: Password input with strength indicator
/// Step 2: Email verification (6-digit code)
/// Step 3: Birthday picker
/// Step 4: Gender selection
/// Step 5: Country selection
/// Step 6: Topics selection
/// Step 7: Confirmation
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key, this.prefillEmail});

  final String? prefillEmail;

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _pageController = PageController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  int _currentStep = 0;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  DateTime _selectedBirthdate = DateTime.now();
  // ignore: unused_field
  String _selectedGender = '';
  List<String> _selectedTopicImages = [];
  List<String> _selectedTopicCategories = [];
  String? _sessionToken;

  @override
  void initState() {
    super.initState();
    if (widget.prefillEmail != null && widget.prefillEmail!.isNotEmpty) {
      _emailController.text = widget.prefillEmail!;
    }
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  String? _emailError;

  void _onEmailChanged() {
    final text = _emailController.text.trim();
    final error = text.isEmpty ? null : Validators.email(text);
    final valid = text.isNotEmpty && error == null;
    if (valid != _isEmailValid || error != _emailError) {
      setState(() {
        _isEmailValid = valid;
        _emailError = error;
      });
    }
  }

  void _onPasswordChanged() {
    final valid = _passwordController.text.length >= 8;
    if (valid != _isPasswordValid) setState(() => _isPasswordValid = valid);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleBack() {
    if (_currentStep == 3) {
      // From birthday, skip verification step and go back to password.
      _goToStep(1);
    } else if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleNextEmail() async {
    if (!_isEmailValid) return;
    // Re-validate before proceeding
    final error = Validators.email(_emailController.text.trim());
    if (error != null) {
      setState(() => _emailError = error);
      return;
    }

    final email = _emailController.text.trim();
    setState(() => _isLoading = true);
    try {
      final exists = await ref.read(authProvider.notifier).isEmailRegistered(
            context: context,
            email: email,
          );
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (exists) {
        // Email already in Clerk → pop signup, open login with pre-filled email.
        // Capture translated message before popping (context may become invalid).
        final message = context.tr('auth.emailAlreadyRegistered');
        Navigator.of(context).pop();
        // Use global messenger so toast survives the bottom-sheet dismissal.
        AppToast.info(null, message: message);
        if (context.mounted) {
          showLoginBottomSheet(context, prefillEmail: email);
        }
      } else {
        _goToStep(1);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      // On failure, allow user to proceed normally.
      _goToStep(1);
    }
  }

  Future<void> _handleNextPassword() async {
    if (!_isPasswordValid) return;
    setState(() => _isLoading = true);
    try {
      final result = await ref.read(authProvider.notifier).createAccount(
            context: context,
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (!mounted) return;
      setState(() => _isLoading = false);
      _sessionToken = result.token;

      if (result.needsVerification) {
        // Go to email verification step
        _goToStep(2);
      } else {
        // No verification needed — skip to birthday
        _goToStep(3);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final errorMsg = e.toString().toLowerCase();
      // If email already exists in Clerk, pop signup and show login with prefilled email.
      if (errorMsg.contains('already') ||
          errorMsg.contains('taken') ||
          errorMsg.contains('exists') ||
          errorMsg.contains('unique') ||
          errorMsg.contains('that email address is taken')) {
        final email = _emailController.text.trim();
        Navigator.of(context).pop(); // close signup
        if (context.mounted) {
          showLoginBottomSheet(context, prefillEmail: email);
        }
        return;
      }

      AppToast.error(context, message: e.toString());
    }
  }

  void _handleEmailVerified(String sessionToken) {
    _sessionToken = sessionToken;
    _goToStep(3);
  }

  void _handleNextBirthday() {
    // Save birthday step details to local storage
    final profile = UserProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      dateOfBirth: _selectedBirthdate.toIso8601String(),
    );
    ref.read(userProfileDatasourceProvider).saveProfile(profile);
    _goToStep(4);
  }

  void _handleGenderSelected(String gender) {
    setState(() => _selectedGender = gender);
    _goToStep(5);
  }

  void _handleCountryNext(String country) => _goToStep(6);

  void _handleTopicsNext(TopicSelectionResult result) {
    setState(() {
      _selectedTopicImages = result.imageUrls;
      _selectedTopicCategories = result.categories;
    });
    _goToStep(7);
  }

  void _handleConfirmationComplete() {
    _completeSignUp();
  }

  Future<void> _completeSignUp() async {
    // Save user profile locally for personalised feed.
    final name = _nameController.text.trim();
    final profile = UserProfile(
      name: name,
      email: _emailController.text.trim(),
      dateOfBirth: _selectedBirthdate.toIso8601String(),
      gender: _selectedGender,
      selectedTopics: _selectedTopicCategories,
    );
    await ref.read(userProfileDatasourceProvider).saveProfile(profile);

    // Push name to Clerk so it persists across devices/sessions.
    if (name.isNotEmpty && mounted) {
      try {
        final clerkAuth = ClerkAuth.of(context, listen: false);
        final parts = name.split(' ');
        final firstName = parts.first;
        final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : null;
        await clerkAuth.updateUser(
          firstName: firstName,
          lastName: lastName,
        );
      } catch (_) {
        // Non-critical: name saved locally, Clerk update is best-effort.
      }
    }

    final token = _sessionToken ?? 'signup_${DateTime.now().millisecondsSinceEpoch}';
    await ref.read(authProvider.notifier).markAuthenticated(
      token,
      context: context,
    );
    // Auth state update triggers router redirect to home.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            if (_currentStep < 7) ...[
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: _buildTopBar(),
              ),
            ],
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 8,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return _EmailStep(
                        controller: _emailController,
                        isValid: _isEmailValid,
                        isLoading: _isLoading,
                        emailError: _emailError,
                        onNext: _handleNextEmail,
                      );
                    case 1:
                      return _PasswordStep(
                        controller: _passwordController,
                        isValid: _isPasswordValid,
                        isLoading: _isLoading,
                        obscure: _obscurePassword,
                        onToggleObscure: () {
                          setState(
                            () => _obscurePassword = !_obscurePassword,
                          );
                        },
                        onNext: _handleNextPassword,
                      );
                    case 2:
                      return SignupEmailVerificationStep(
                        email: _emailController.text.trim(),
                        onVerified: _handleEmailVerified,
                      );
                    case 3:
                      return SignupBirthdayStep(
                        nameController: _nameController,
                        email: _emailController.text.trim(),
                        selectedDate: _selectedBirthdate,
                        onDateChanged: (date) {
                          setState(() => _selectedBirthdate = date);
                        },
                        onNameUpdated: () {
                          FocusScope.of(context).unfocus();
                        },
                        onNext: _handleNextBirthday,
                      );
                    case 4:
                      return SignupGenderStep(
                        onSelected: _handleGenderSelected,
                      );
                    case 5:
                      return SignupCountryStep(
                        onNext: _handleCountryNext,
                      );
                    case 6:
                      return SignupTopicsStep(
                        onNext: _handleTopicsNext,
                      );
                    case 7:
                      return SignupConfirmationStep(
                        selectedTopicImages: _selectedTopicImages,
                        onComplete: _handleConfirmationComplete,
                      );
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 40.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: _handleBack,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimaryDark,
                size: 20.w,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_kTotalSteps, (index) {
              final isActive = index == _currentStep;
              final isPast = index < _currentStep;
              return Container(
                width: isActive ? 8.w : 6.w,
                height: isActive ? 8.w : 6.w,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPast
                      ? AppColors.textPrimaryDark
                      : isActive
                          ? Colors.transparent
                          : AppColors.textTertiaryDark,
                  border: isActive
                      ? Border.all(
                          color: AppColors.textPrimaryDark,
                          width: 1.5.w,
                        )
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Step 0: Email
// ─────────────────────────────────────────────────────────
class _EmailStep extends StatelessWidget {
  const _EmailStep({
    required this.controller,
    required this.isValid,
    required this.isLoading,
    required this.onNext,
    this.emailError,
  });

  final TextEditingController controller;
  final bool isValid;
  final bool isLoading;
  final VoidCallback onNext;
  final String? emailError;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Text(
            context.tr('auth.whatsYourEmail'),
            style: AppTypography.h2.copyWith(
              color: AppColors.textPrimaryDark,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          AppTextField(
            controller: controller,
            hint: context.tr('auth.enterYourEmailAddress'),
            keyboardType: TextInputType.emailAddress,
            borderRadius: 16.r,
          ),
          if (emailError != null) ...[
            SizedBox(height: 6.h),
            Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Text(
                emailError!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.pinterestRed,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
          SizedBox(height: 24.h),
          AppButton(
            label: context.tr('general.next'),
            onPressed: onNext,
            isEnabled: isValid,
            isLoading: isLoading,
            backgroundColor: AppColors.pinterestRed,
            foregroundColor: AppColors.textPrimaryDark,
            disabledBackgroundColor: const Color(0xFF5F5F5F),
            disabledForegroundColor: const Color(0xFF9B9B9B),
            height: 42.h,
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Step 1: Password
// ─────────────────────────────────────────────────────────
class _PasswordStep extends StatefulWidget {
  const _PasswordStep({
    required this.controller,
    required this.isValid,
    required this.isLoading,
    required this.obscure,
    required this.onToggleObscure,
    required this.onNext,
  });

  final TextEditingController controller;
  final bool isValid;
  final bool isLoading;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onNext;

  @override
  State<_PasswordStep> createState() => _PasswordStepState();
}

class _PasswordStepState extends State<_PasswordStep> {
  double _strength = 0;
  String _password = '';

  @override
  void initState() {
    super.initState();
    _password = widget.controller.text;
    _strength = _passwordStrength(_password);
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    final text = widget.controller.text;
    if (text != _password) {
      setState(() {
        _password = text;
        _strength = _passwordStrength(text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),

          // ── Title (centered) ──
          Center(
            child: Text(
              context.tr('auth.createAPassword'),
              style: AppTypography.h2.copyWith(
                color: AppColors.textPrimaryDark,
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // ── Password field ──
          AppTextField(
            controller: widget.controller,
            label: context.tr('auth.password'),
            hint: context.tr('auth.createAStrongPassword'),
            obscureText: widget.obscure,
            borderRadius: 16.r,
            suffixIcon: IconButton(
              icon: Icon(
                widget.obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textPrimaryDark,
                size: 20.w,
              ),
              onPressed: widget.onToggleObscure,
            ),
          ),
          SizedBox(height: 12.h),

          // ── Strength bar + label ──
          if (_password.isNotEmpty) ...[
            _PasswordStrengthBar(strength: _strength),
            SizedBox(height: 6.h),
            Text(
              _strengthLabel(context, _strength),
              style: AppTypography.bodySmall.copyWith(
                color: _strengthColor(_strength),
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 2.h),
          ],

          // ── Requirement hint ──
          Text(
            context.tr('auth.passwordRequirement'),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiaryDark,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 12.h),

          // ── Password tips link ──
          GestureDetector(
            onTap: () => _showPasswordTips(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr('auth.passwordTips'),
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.info_outline,
                  color: AppColors.textSecondaryDark,
                  size: 16.w,
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // ── Next button ──
          AppButton(
            label: context.tr('general.next'),
            onPressed: widget.onNext,
            isEnabled: widget.isValid,
            isLoading: widget.isLoading,
            backgroundColor: AppColors.pinterestRed,
            foregroundColor: AppColors.textPrimaryDark,
            disabledBackgroundColor: const Color(0xFF5F5F5F),
            disabledForegroundColor: const Color(0xFF9B9B9B),
            height: 42.h,
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  // 0.0 – 1.0
  double _passwordStrength(String password) {
    if (password.isEmpty) return 0;
    var score = 0.0;
    if (password.length >= 8) score += 0.25;
    if (password.length >= 12) score += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 0.2;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score += 0.2;
    return score.clamp(0.0, 1.0);
  }

  String _strengthLabel(BuildContext context, double strength) {
    if (strength >= 0.9) return context.tr('auth.strengthPerfection');
    if (strength >= 0.7) return context.tr('auth.strengthStrong');
    if (strength >= 0.5) return context.tr('auth.strengthGood');
    if (strength >= 0.25) return context.tr('auth.strengthFair');
    return context.tr('auth.strengthWeak');
  }

  Color _strengthColor(double strength) {
    if (strength >= 0.7) return const Color(0xFF4CAF50);
    if (strength >= 0.5) return const Color(0xFFFFC107);
    if (strength >= 0.25) return const Color(0xFFFF9800);
    return AppColors.pinterestRed;
  }

  void _showPasswordTips(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: AppBorders.bottomSheet),
      builder: (_) => _PasswordTipsSheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Password strength bar
// ─────────────────────────────────────────────────────────
class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.strength});

  final double strength;

  Color get _color {
    if (strength >= 0.7) return const Color(0xFF4CAF50);
    if (strength >= 0.5) return const Color(0xFFFFC107);
    if (strength >= 0.25) return const Color(0xFFFF9800);
    return AppColors.pinterestRed;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2.r),
      child: SizedBox(
        height: 4.h,
        child: LinearProgressIndicator(
          value: strength,
          backgroundColor: AppColors.textTertiaryDark.withValues(alpha: 0.3),
          valueColor: AlwaysStoppedAnimation<Color>(_color),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Password tips bottom sheet
// ─────────────────────────────────────────────────────────
class _PasswordTipsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bodyStyle = AppTypography.bodyMedium.copyWith(
      color: AppColors.textPrimaryDark,
      fontSize: 14.sp,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('auth.passwordTips'),
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            context.tr('auth.passwordTipsBody'),
            style: bodyStyle.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16.h),
          Text(
            context.tr('auth.whatToAvoid'),
            style: bodyStyle.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8.h),
          _bullet(context.tr('auth.avoidCommonPasswords'), bodyStyle),
          SizedBox(height: 4.h),
          _bullet(context.tr('auth.avoidRecentDates'), bodyStyle),
          SizedBox(height: 4.h),
          _bullet(context.tr('auth.avoidSimplePatterns'), bodyStyle),
          SizedBox(height: 24.h),
          AppButton(
            label: context.tr('general.ok'),
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: AppColors.pinterestRed,
            foregroundColor: AppColors.textPrimaryDark,
            height: 48.h,
          ),
          SizedBox(
            height: MediaQuery.paddingOf(context).bottom + 8.h,
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text, TextStyle style) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• ', style: style),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}
