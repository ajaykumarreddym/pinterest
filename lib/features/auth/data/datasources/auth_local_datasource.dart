import 'package:pinterest/core/constants/storage_keys.dart';
import 'package:pinterest/core/services/storage/app_storage.dart';

/// Local data source for caching auth state.
abstract class AuthLocalDatasource {
  Future<void> cacheAuthToken(String token);
  String? getAuthToken();
  Future<void> clearAuth();
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
  Future<void> setOnboardingComplete() async {
    await storage.setBool(StorageKeys.onboardingComplete, value: true);
  }

  @override
  bool isOnboardingComplete() {
    return storage.getBool(StorageKeys.onboardingComplete) ?? false;
  }
}
