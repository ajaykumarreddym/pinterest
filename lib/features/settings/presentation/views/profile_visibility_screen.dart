import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:pinterest/features/settings/presentation/widgets/settings_scaffold.dart';

/// Profile visibility settings screen.
class ProfileVisibilityScreen extends ConsumerStatefulWidget {
  const ProfileVisibilityScreen({super.key});

  @override
  ConsumerState<ProfileVisibilityScreen> createState() =>
      _ProfileVisibilityScreenState();
}

class _ProfileVisibilityScreenState
    extends ConsumerState<ProfileVisibilityScreen> {
  late bool _isPublic;

  @override
  void initState() {
    super.initState();
    final ds = ref.read(settingsDatasourceProvider);
    _isPublic = ds.getProfileVisibility() == 'public';
  }

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Profile visibility',
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.space5),
        child: Column(
          children: [
            SettingsToggleTile(
              title: 'Private profile',
              subtitle:
                  'When enabled, only approved followers can see your pins.',
              value: !_isPublic,
              onChanged: (val) {
                setState(() => _isPublic = !val);
                ref.read(settingsDatasourceProvider).setProfileVisibility(
                      _isPublic ? 'public' : 'private',
                    );
              },
            ),
            SettingsToggleTile(
              title: 'Show in search results',
              subtitle: 'Allow your profile to appear in search results.',
              value: _isPublic,
              onChanged: (val) {
                setState(() => _isPublic = val);
                ref.read(settingsDatasourceProvider).setProfileVisibility(
                      _isPublic ? 'public' : 'private',
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
