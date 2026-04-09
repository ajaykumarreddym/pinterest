import 'package:flutter/material.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/settings/presentation/widgets/settings_scaffold.dart';

/// Privacy Policy screen.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Privacy Policy',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pinterest Privacy Policy',
              style: AppTypography.h2.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
            SizedBox(height: AppSpacing.space5),
            _buildSection(
              'Information We Collect',
              'We collect information you provide directly to us, such as when you create an account, save Pins, or contact us. This includes your name, email, and activity data.',
            ),
            _buildSection(
              'How We Use Information',
              'We use the information we collect to provide, maintain, and improve our services, to personalise your experience, and to send you updates and recommendations.',
            ),
            _buildSection(
              'Information Sharing',
              'We do not share your personal information with companies, organisations, or individuals outside Pinterest except in limited circumstances, such as with your consent.',
            ),
            _buildSection(
              'Data Security',
              'We use appropriate technical and organisational measures to protect the security of your personal information. However, no method of transmission over the Internet is completely secure.',
            ),
            _buildSection(
              'Your Choices',
              'You can control your privacy settings, including who can see your profile, boards, and Pins. You can also opt out of personalised ads and data sharing.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          SizedBox(height: AppSpacing.space3),
          Text(
            body,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
