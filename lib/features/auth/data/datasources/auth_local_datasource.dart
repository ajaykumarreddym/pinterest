import 'package:pinterest/core/constants/storage_keys.dart';
import 'package:pinterest/core/services/storage/app_storage.dart';
import 'package:pinterest/core/services/storage/secure_storage.dart';

/// Local data source for caching auth state.
abstract class AuthLocalDatasource {
  Future<void> cacheAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> clearAuth();
  Future<void> clearAllUserData();
  Future<void> setOnboardingComplete();
  bool isOnboardingComplete();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  const AuthLocalDatasourceImpl({
    required this.storage,
    required this.secureStorage,
  });

  final AppStorage storage;
  final SecureStorage secureStorage;

  @override
  Future<void> cacheAuthToken(String token) async {
    await secureStorage.write(StorageKeys.authToken, token);
  }

  @override
  Future<String?> getAuthToken() async {
    return secureStorage.read(StorageKeys.authToken);
  }

  @override
  Future<void> clearAuth() async {
    await secureStorage.delete(StorageKeys.authToken);
    await secureStorage.delete(StorageKeys.userId);
  }

  @override
  Future<void> clearAllUserData() async {
    // Auth (secure storage)
    await secureStorage.delete(StorageKeys.authToken);
    await secureStorage.delete(StorageKeys.refreshToken);
    await secureStorage.delete(StorageKeys.userId);

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
