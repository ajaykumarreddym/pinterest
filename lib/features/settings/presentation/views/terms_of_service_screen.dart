import 'package:flutter/material.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/settings/presentation/widgets/settings_scaffold.dart';

/// Terms of Service screen.
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Terms of Service',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pinterest Terms of Service',
              style: AppTypography.h2.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
            SizedBox(height: AppSpacing.space5),
            _buildSection(
              'Welcome to Pinterest',
              'These Terms of Service govern your use of Pinterest and provide information about the Pinterest Service. When you create a Pinterest account or use Pinterest, you agree to these terms.',
            ),
            _buildSection(
              'The Pinterest Service',
              'Pinterest helps you discover and do what you love. To do that, we show you things we think will be relevant, interesting and personal to you based on your activity.',
            ),
            _buildSection(
              'Your Content',
              'Pinterest allows you to post content, including photos, comments, links, and other materials. Anything that you post or otherwise make available on Pinterest is referred to as "User Content."',
            ),
            _buildSection(
              'General Conditions',
              'We reserve the right to modify or terminate the Pinterest service for any reason, without notice at any time. We reserve the right to refuse service to anyone for any reason at any time.',
            ),
            _buildSection(
              'Copyright Policy',
              'Pinterest has adopted and implemented a policy that provides for the termination of accounts of users who infringe the rights of copyright holders.',
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
