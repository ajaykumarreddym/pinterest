import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:pinterest/core/utils/app_logger.dart';
import 'package:pinterest/features/localization/domain/entities/language_data.dart';

/// Loads language strings from assets/lang/ JSON files.
abstract class LocalizationRemoteDatasource {
  Future<LanguageData> getLanguageData(SupportedLanguage language);
}

class LocalizationRemoteDatasourceImpl implements LocalizationRemoteDatasource {
  @override
  Future<LanguageData> getLanguageData(SupportedLanguage language) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/lang/${language.code}.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      AppLogger.info(
        '📖 Loaded ${language.displayName} strings '
        '(${jsonData.length} sections)',
      );
      return LanguageData(language: language, strings: jsonData);
    } catch (e) {
      AppLogger.error('Failed to load ${language.code}.json', error: e);
      rethrow;
    }
  }
}
