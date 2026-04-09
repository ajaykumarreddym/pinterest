import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/settings/presentation/widgets/settings_scaffold.dart';

/// Help Centre screen with FAQ sections.
class HelpCentreScreen extends StatelessWidget {
  const HelpCentreScreen({super.key});

  static const _faqs = [
    _Faq(
      question: 'How do I save a Pin?',
      answer:
          'Tap the save button on any Pin to add it to a board. You can create new boards or save to existing ones.',
    ),
    _Faq(
      question: 'How do I create a board?',
      answer:
          'Go to your profile, tap the Boards tab, then tap "Create a board". Give your board a name and optional description.',
    ),
    _Faq(
      question: 'How do I change my password?',
      answer:
          'Go to Settings > Security. You can update your password or enable two-factor authentication.',
    ),
    _Faq(
      question: 'How do I delete my account?',
      answer:
          'Go to Settings > Account management. Scroll down and tap "Delete account". This action cannot be undone.',
    ),
    _Faq(
      question: 'How do I report content?',
      answer:
          'Tap the three dots on any Pin and select "Report Pin". Choose the reason and submit your report.',
    ),
    _Faq(
      question: 'How do I contact support?',
      answer:
          'You can reach Pinterest support at help.pinterest.com or through the Help Centre in the app.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Help Centre',
      body: ListView.separated(
        padding: EdgeInsets.all(AppSpacing.space5),
        itemCount: _faqs.length,
        separatorBuilder: (_, __) => Divider(
          color: AppColors.dividerDark,
          height: 1.h,
        ),
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.only(bottom: AppSpacing.space5),
            iconColor: AppColors.textSecondaryDark,
            collapsedIconColor: AppColors.textSecondaryDark,
            title: Text(
              faq.question,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
            children: [
              Text(
                faq.answer,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Faq {
  const _Faq({required this.question, required this.answer});
  final String question;
  final String answer;
}
