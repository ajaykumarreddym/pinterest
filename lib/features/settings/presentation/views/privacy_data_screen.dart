import 'package:flutter/material.dart';

import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/features/settings/presentation/widgets/settings_scaffold.dart';

/// Privacy and data settings screen.
class PrivacyDataScreen extends StatefulWidget {
  const PrivacyDataScreen({super.key});

  @override
  State<PrivacyDataScreen> createState() => _PrivacyDataScreenState();
}

class _PrivacyDataScreenState extends State<PrivacyDataScreen> {
  bool _personalisation = true;
  bool _dataSharing = false;
  bool _searchHistory = true;
  bool _adPersonalisation = true;

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Privacy and data',
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.space5),
        child: ListView(
          children: [
            SettingsToggleTile(
              title: 'Personalisation',
              subtitle: 'Allow Pinterest to personalise your experience.',
              value: _personalisation,
              onChanged: (val) => setState(() => _personalisation = val),
            ),
            SettingsToggleTile(
              title: 'Data sharing',
              subtitle: 'Share usage data to help improve Pinterest.',
              value: _dataSharing,
              onChanged: (val) => setState(() => _dataSharing = val),
            ),
            SettingsToggleTile(
              title: 'Search history',
              subtitle: 'Save your search history for better suggestions.',
              value: _searchHistory,
              onChanged: (val) => setState(() => _searchHistory = val),
            ),
            SettingsToggleTile(
              title: 'Ad personalisation',
              subtitle: 'Show personalised ads based on your activity.',
              value: _adPersonalisation,
              onChanged: (val) => setState(() => _adPersonalisation = val),
            ),
          ],
        ),
      ),
    );
  }
}
