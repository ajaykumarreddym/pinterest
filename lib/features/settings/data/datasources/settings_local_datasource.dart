import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/core/constants/storage_keys.dart';
import 'package:pinterest/core/di/injection.dart';
import 'package:pinterest/core/services/storage/app_storage.dart';

/// Provider for settings local datasource.
final settingsDatasourceProvider = Provider<SettingsLocalDatasource>((ref) {
  return SettingsLocalDatasource(storage: ref.read(appStorageProvider));
});

/// Local storage for user settings preferences.
class SettingsLocalDatasource {
  const SettingsLocalDatasource({required this.storage});

  final AppStorage storage;

  // ── Notifications ──
  Future<void> setNotificationsEnabled({required bool enabled}) async {
    await storage.setBool(StorageKeys.notificationsEnabled, value: enabled);
  }

  bool getNotificationsEnabled() {
    return storage.getBool(StorageKeys.notificationsEnabled) ?? true;
  }

  // ── Profile Visibility ──
  Future<void> setProfileVisibility(String visibility) async {
    await storage.setString(StorageKeys.profileVisibility, visibility);
  }

  String getProfileVisibility() {
    return storage.getString(StorageKeys.profileVisibility) ?? 'public';
  }

  // ── Feed Layout ──
  Future<void> setFeedLayout(String layout) async {
    await storage.setString(StorageKeys.feedLayout, layout);
  }

  String getFeedLayout() {
    return storage.getString(StorageKeys.feedLayout) ?? 'compact';
  }
}
