import 'package:pinterest/core/constants/storage_keys.dart';
import 'package:pinterest/core/services/storage/app_storage.dart';

/// Local data source for caching auth state.
abstract class AuthLocalDatasource {
  Future<void> cacheAuthToken(String token);
  String? getAuthToken();
  Future<void> clearAuth();
  Future<void> clearAllUserData();
  Future<void> setOnboardingComplete();
  bool isOnboardingComplete();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  const AuthLocalDatasourceImpl({required this.storage});

  final AppStorage storage;

  @override
  Future<void> cacheAuthToken(String token) async {
    await storage.setString(StorageKeys.authToken, token);
  }

  @override
  String? getAuthToken() {
    return storage.getString(StorageKeys.authToken);
  }

  @override
  Future<void> clearAuth() async {
    await storage.remove(StorageKeys.authToken);
    await storage.remove(StorageKeys.userId);
  }

  @override
  Future<void> clearAllUserData() async {
    // Auth
    await storage.remove(StorageKeys.authToken);
    await storage.remove(StorageKeys.refreshToken);
    await storage.remove(StorageKeys.userId);

    // User profile
    await storage.remove(StorageKeys.userProfile);

    // User content
    await storage.remove(StorageKeys.savedPins);
    await storage.remove(StorageKeys.likedPinIds);
    await storage.remove(StorageKeys.reportedPinIds);
    await storage.remove(StorageKeys.hiddenPinIds);
    await storage.remove(StorageKeys.createdPins);
    await storage.remove(StorageKeys.boards);
    await storage.remove(StorageKeys.collages);

    // Search history
    await storage.remove(StorageKeys.searchHistory);

    // Cached API data
    await storage.remove(StorageKeys.cachedPhotos);

    // Messages/Inbox
    await storage.remove(StorageKeys.cachedConversations);
    await storage.remove(StorageKeys.cachedInboxUpdates);
    await storage.remove(StorageKeys.cachedMessages);

    // User settings
    await storage.remove(StorageKeys.notificationsEnabled);
    await storage.remove(StorageKeys.profileVisibility);
    await storage.remove(StorageKeys.feedLayout);

    // Onboarding (so user goes through it again on re-login)
    await storage.remove(StorageKeys.onboardingComplete);
  }

  @override
  Future<void> setOnboardingComplete() async {
    await storage.setBool(StorageKeys.onboardingComplete, value: true);
  }

  @override
  bool isOnboardingComplete() {
    return storage.getBool(StorageKeys.onboardingComplete) ?? false;
  }
}
