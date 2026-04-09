import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/auth/domain/entities/user_profile.dart';
import 'package:pinterest/features/auth/presentation/providers/auth_providers.dart';
import 'package:pinterest/features/settings/presentation/widgets/settings_scaffold.dart';

/// Account management screen — edit name, email, password.
class AccountManagementScreen extends ConsumerStatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  ConsumerState<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState
    extends ConsumerState<AccountManagementScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileDatasourceProvider).getProfile();
    _nameController = TextEditingController(text: profile?.name ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final clerkAuth = ClerkAuth.of(context);
    final user = clerkAuth.user;
    if (user != null) {
      if (_nameController.text.isEmpty && user.name.isNotEmpty) {
        _nameController.text = user.name;
      }
      final email = user.email;
      if (_emailController.text.isEmpty && email != null && email.isNotEmpty) {
        _emailController.text = email;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final datasource = ref.read(userProfileDatasourceProvider);
    final current = datasource.getProfile();
    final updated = (current ?? const UserProfile()).copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
    );
    await datasource.saveProfile(updated);
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated'),
          backgroundColor: AppColors.surfaceVariantDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppBorders.md),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Account management',
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField('Name', _nameController),
            SizedBox(height: AppSpacing.space5),
            _buildField('Email', _emailController, readOnly: true),
            SizedBox(height: AppSpacing.space7),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pinterestRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorders.full,
                  ),
                ),
                child: _isSaving
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Save', style: AppTypography.labelLarge),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        SizedBox(height: AppSpacing.space2),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space1,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariantDark,
            borderRadius: AppBorders.md,
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            style: AppTypography.bodyLarge.copyWith(
              color: readOnly
                  ? AppColors.textTertiaryDark
                  : AppColors.textPrimaryDark,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.space3),
            ),
          ),
        ),
      ],
    );
  }
}
