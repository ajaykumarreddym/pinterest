import 'dart:convert';

import 'package:pinterest/core/constants/storage_keys.dart';
import 'package:pinterest/core/services/storage/app_storage.dart';
import 'package:pinterest/core/utils/app_logger.dart';

/// Caches language code and strings in local storage.
abstract class LocalizationLocalDatasource {
  String? getCurrentLanguageCode();
  Future<void> setCurrentLanguageCode(String code);
  Future<void> cacheLanguageStrings(Map<String, dynamic> strings);
  Map<String, dynamic>? getCachedLanguageStrings();
}

class LocalizationLocalDatasourceImpl implements LocalizationLocalDatasource {
  LocalizationLocalDatasourceImpl({required this.storage});

  final AppStorage storage;

  @override
  String? getCurrentLanguageCode() {
    return storage.getString(StorageKeys.languageCode);
  }

  @override
  Future<void> setCurrentLanguageCode(String code) async {
    await storage.setString(StorageKeys.languageCode, code);
    AppLogger.info('💾 Language code cached: $code');
  }

  @override
  Future<void> cacheLanguageStrings(Map<String, dynamic> strings) async {
    final encoded = json.encode(strings);
    await storage.setString(StorageKeys.cachedLanguageStrings, encoded);
    AppLogger.info('💾 Language strings cached (${encoded.length} chars)');
  }

  @override
  Map<String, dynamic>? getCachedLanguageStrings() {
    final encoded = storage.getString(StorageKeys.cachedLanguageStrings);
    if (encoded == null) return null;
    return json.decode(encoded) as Map<String, dynamic>;
  }
}
