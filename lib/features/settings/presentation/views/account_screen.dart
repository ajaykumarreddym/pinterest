import 'package:cached_network_image/cached_network_image.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/auth/presentation/providers/auth_providers.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';
import 'package:pinterest/features/settings/presentation/views/about_screen.dart';
import 'package:pinterest/features/settings/presentation/views/account_management_screen.dart';
import 'package:pinterest/features/settings/presentation/views/add_account_screen.dart';
import 'package:pinterest/features/settings/presentation/views/claimed_accounts_screen.dart';
import 'package:pinterest/features/settings/presentation/views/help_centre_screen.dart';
import 'package:pinterest/features/settings/presentation/views/notifications_screen.dart';
import 'package:pinterest/features/settings/presentation/views/privacy_data_screen.dart';
import 'package:pinterest/features/settings/presentation/views/privacy_policy_screen.dart';
import 'package:pinterest/features/settings/presentation/views/profile_visibility_screen.dart';
import 'package:pinterest/features/settings/presentation/views/refine_recommendations_screen.dart';
import 'package:pinterest/features/settings/presentation/views/reports_violations_screen.dart';
import 'package:pinterest/features/settings/presentation/views/security_screen.dart';
import 'package:pinterest/features/settings/presentation/views/social_permissions_screen.dart';
import 'package:pinterest/features/settings/presentation/views/terms_of_service_screen.dart';

/// "Your account" settings screen matching the Pinterest design.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clerkAuth = ClerkAuth.of(context);
    final user = clerkAuth.user;
    final isSignedIn = clerkAuth.isSignedIn;
    final localProfile = ref.read(userProfileDatasourceProvider).getProfile();

    final displayName = user?.name.isNotEmpty == true
        ? user!.name
        : (localProfile?.name?.isNotEmpty == true
            ? localProfile!.name!
            : 'Guest');
    final email = user?.email;
    final username = user?.username ??
        (email != null ? '@${email.split('@').first}' : null) ??
        (localProfile?.email != null
            ? '@${localProfile!.email!.split('@').first}'
            : null);
    final avatarUrl = user?.imageUrl;
    final hasAvatar = user?.hasImage == true && avatarUrl != null;
    final initials = _getInitials(displayName);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimaryDark,
            size: 20.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          context.tr('settings.yourAccount'),
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.space5),
        children: [
          SizedBox(height: AppSpacing.space5),

          // ── Profile Card ──
          if (isSignedIn) ...[
            _ProfileCard(
              displayName: displayName,
              username: username,
              hasAvatar: hasAvatar,
              avatarUrl: avatarUrl,
              initials: initials,
            ),
            SizedBox(height: AppSpacing.space7),
          ],

          // ── Settings Section ──
          _SectionHeader(title: context.tr('settings.settings')),
          SizedBox(height: AppSpacing.space5),
          _SettingsTile(
            title: context.tr('settings.accountManagement'),
            onTap: () => _push(context, const AccountManagementScreen()),
          ),
          _SettingsTile(
            title: context.tr('settings.profileVisibility'),
            onTap: () => _push(context, const ProfileVisibilityScreen()),
          ),
          _SettingsTile(
            title: context.tr('settings.refineRecommendations'),
            onTap: () =>
                _push(context, const RefineRecommendationsScreen()),
          ),
          _SettingsTile(
            title: context.tr('settings.claimedExternalAccounts'),
            onTap: () => _push(context, const ClaimedAccountsScreen()),
          ),
          _SettingsTile(
            title: context.tr('settings.socialPermissions'),
            onTap: () => _push(context, const SocialPermissionsScreen()),
          ),
          _SettingsTile(
            title: context.tr('settings.notifications'),
            onTap: () => _push(context, const NotificationsScreen()),
          ),
          _SettingsTile(
            title: context.tr('settings.privacyAndData'),
            onTap: () => _push(context, const PrivacyDataScreen()),
          ),
          _SettingsTile(
            title: context.tr('settings.reportsAndViolations'),
            onTap: () => _push(context, const ReportsViolationsScreen()),
          ),

          SizedBox(height: AppSpacing.space5),

          // ── Login Section ──
          _SectionHeader(title: context.tr('settings.login')),
          SizedBox(height: AppSpacing.space5),
          _SettingsTile(
            title: context.tr('settings.addAccount'),
            onTap: () => _push(context, const AddAccountScreen()),
          ),
          _SettingsTile(
            title: context.tr('settings.security'),
            onTap: () => _push(context, const SecurityScreen()),
          ),

          SizedBox(height: AppSpacing.space3),

          // ── Log out ──
          _SettingsTile(
            title: context.tr('settings.logOut'),
            showChevron: false,
            onTap: () async {
              await ref.read(authProvider.notifier).logout(context: context);
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),

          SizedBox(height: AppSpacing.space5),

          // ── Support Section ──
          _SectionHeader(title: context.tr('settings.support')),
          SizedBox(height: AppSpacing.space5),
          _SettingsTile(
            title: context.tr('settings.helpCentre'),
            onTap: () => _push(context, const HelpCentreScreen()),
          ),
          _SettingsTile(
            title: context.tr('settings.termsOfService'),
            onTap: () => _push(context, const TermsOfServiceScreen()),
          ),
          _SettingsTile(
            title: context.tr('settings.privacyPolicy'),
            onTap: () => _push(context, const PrivacyPolicyScreen()),
          ),
          _SettingsTile(
            title: context.tr('settings.about'),
            onTap: () => _push(context, const AboutScreen()),
          ),

          SizedBox(height: AppSpacing.space9),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }
}

// ── Profile Card ──

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.displayName,
    required this.username,
    required this.hasAvatar,
    required this.avatarUrl,
    required this.initials,
  });

  final String displayName;
  final String? username;
  final bool hasAvatar;
  final String? avatarUrl;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.space5),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: AppBorders.lg,
        border: Border.all(color: AppColors.dividerDark),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildAvatar(),
              SizedBox(width: AppSpacing.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    if (username != null) ...[
                      SizedBox(height: AppSpacing.space1),
                      Text(
                        username!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiaryDark,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.space5),
          Row(
            children: [
              Expanded(
                child: _CardButton(
                  label: context.tr('settings.viewProfile'),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              SizedBox(width: AppSpacing.space3),
              Expanded(
                child: _CardButton(
                  label: context.tr('settings.shareProfile'),
                  onTap: () {
                    // TODO: Share profile link
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (hasAvatar && avatarUrl != null) {
      return CircleAvatar(
        radius: 28.r,
        backgroundColor: AppColors.surfaceVariantDark,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: avatarUrl!,
            width: 56.w,
            height: 56.w,
            fit: BoxFit.cover,
            placeholder: (_, __) => _buildInitials(),
            errorWidget: (_, __, ___) => _buildInitials(),
          ),
        ),
      );
    }
    return _buildInitials();
  }

  Widget _buildInitials() {
    return CircleAvatar(
      radius: 28.r,
      backgroundColor: AppColors.pinterestRed,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Card Button ──

class _CardButton extends StatelessWidget {
  const _CardButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorders.full,
      child: Container(
        height: 40.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: AppBorders.full,
          border: Border.all(color: AppColors.dividerDark),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
      ),
    );
  }
}

// ── Section Header ──

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondaryDark,
      ),
    );
  }
}

// ── Settings Tile ──

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.onTap,
    this.showChevron = true,
  });

  final String title;
  final VoidCallback onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.space5),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ),
            if (showChevron)
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondaryDark,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }
}
