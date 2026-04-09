import 'package:flutter/material.dart';

import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/features/settings/presentation/widgets/settings_scaffold.dart';

/// Security settings screen.
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _twoFactor = false;
  bool _biometric = false;

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Security',
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.space5),
        child: ListView(
          children: [
            SettingsToggleTile(
              title: 'Two-factor authentication',
              subtitle:
                  'Add an extra layer of security to your account.',
              value: _twoFactor,
              onChanged: (val) => setState(() => _twoFactor = val),
            ),
            SettingsToggleTile(
              title: 'Biometric login',
              subtitle: 'Use fingerprint or face recognition to log in.',
              value: _biometric,
              onChanged: (val) => setState(() => _biometric = val),
            ),
          ],
        ),
      ),
    );
  }
}
