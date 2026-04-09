import 'package:flutter/material.dart';

import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/features/settings/presentation/widgets/settings_scaffold.dart';

/// Social permissions settings screen.
class SocialPermissionsScreen extends StatefulWidget {
  const SocialPermissionsScreen({super.key});

  @override
  State<SocialPermissionsScreen> createState() =>
      _SocialPermissionsScreenState();
}

class _SocialPermissionsScreenState extends State<SocialPermissionsScreen> {
  bool _allowMessages = true;
  bool _showActivity = true;
  bool _allowMentions = true;

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Social permissions',
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.space5),
        child: ListView(
          children: [
            SettingsToggleTile(
              title: 'Allow messages',
              subtitle: 'Let others send you messages.',
              value: _allowMessages,
              onChanged: (val) => setState(() => _allowMessages = val),
            ),
            SettingsToggleTile(
              title: 'Show activity status',
              subtitle: 'Let others see when you are online.',
              value: _showActivity,
              onChanged: (val) => setState(() => _showActivity = val),
            ),
            SettingsToggleTile(
              title: 'Allow mentions',
              subtitle: 'Let others mention you in comments.',
              value: _allowMentions,
              onChanged: (val) => setState(() => _allowMentions = val),
            ),
          ],
        ),
      ),
    );
  }
}
