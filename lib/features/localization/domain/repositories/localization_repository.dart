import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/features/localization/domain/entities/language_data.dart';

/// Contract for localization data operations.
abstract class LocalizationRepository {
  /// Loads language strings for [language] from assets.
  Future<Either<Failure, LanguageData>> getLanguageData(
    SupportedLanguage language,
  );

  /// Returns the cached language code, or null if none.
  String? getCurrentLanguageCode();

  /// Persists the selected language code.
  Future<void> setCurrentLanguageCode(String code);

  /// Caches the loaded language strings for offline access.
  Future<void> cacheLanguageStrings(Map<String, dynamic> strings);

  /// Returns cached strings, or null if none.
  Map<String, dynamic>? getCachedLanguageStrings();
}
