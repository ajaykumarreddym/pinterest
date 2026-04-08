import 'dart:convert';

import 'package:pinterest/core/constants/storage_keys.dart';
import 'package:pinterest/core/services/storage/app_storage.dart';
import 'package:pinterest/core/utils/app_logger.dart';
import 'package:pinterest/features/auth/domain/entities/user_profile.dart';

/// Local datasource for the signed-up user's profile preferences.
abstract class UserProfileDatasource {
  Future<void> saveProfile(UserProfile profile);
  UserProfile? getProfile();
  List<String> getSelectedTopics();
  Future<void> clearProfile();
}

class UserProfileDatasourceImpl implements UserProfileDatasource {
  const UserProfileDatasourceImpl({required this.storage});

  final AppStorage storage;

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final json = jsonEncode(profile.toJson());
    await storage.setString(StorageKeys.userProfile, json);
    AppLogger.info('💾 User profile saved (topics: ${profile.selectedTopics.length})');
  }

  @override
  UserProfile? getProfile() {
    final raw = storage.getString(StorageKeys.userProfile);
    if (raw == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('❌ Failed to parse user profile', error: e);
      return null;
    }
  }

  @override
  List<String> getSelectedTopics() {
    return getProfile()?.selectedTopics ?? [];
  }

  @override
  Future<void> clearProfile() async {
    await storage.remove(StorageKeys.userProfile);
  }
}
