import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:pinterest/features/settings/presentation/widgets/settings_scaffold.dart';

/// Notifications settings screen with toggle switches.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  late bool _pushEnabled;
  bool _emailNotifs = true;
  bool _recommendations = true;
  bool _comments = true;
  bool _likes = true;

  @override
  void initState() {
    super.initState();
    _pushEnabled = ref.read(settingsDatasourceProvider).getNotificationsEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Notifications',
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.space5),
        child: ListView(
          children: [
            SettingsToggleTile(
              title: 'Push notifications',
              subtitle: 'Receive push notifications on this device.',
              value: _pushEnabled,
              onChanged: (val) {
                setState(() => _pushEnabled = val);
                ref
                    .read(settingsDatasourceProvider)
                    .setNotificationsEnabled(enabled: val);
              },
            ),
            SettingsToggleTile(
              title: 'Email notifications',
              subtitle: 'Receive updates and activity via email.',
              value: _emailNotifs,
              onChanged: (val) => setState(() => _emailNotifs = val),
            ),
            SettingsToggleTile(
              title: 'Recommendations',
              subtitle: 'Get notified about recommended Pins and boards.',
              value: _recommendations,
              onChanged: (val) => setState(() => _recommendations = val),
            ),
            SettingsToggleTile(
              title: 'Comments',
              subtitle: 'Get notified when someone comments on your Pin.',
              value: _comments,
              onChanged: (val) => setState(() => _comments = val),
            ),
            SettingsToggleTile(
              title: 'Likes',
              subtitle: 'Get notified when someone likes your Pin.',
              value: _likes,
              onChanged: (val) => setState(() => _likes = val),
            ),
          ],
        ),
      ),
    );
  }
}
