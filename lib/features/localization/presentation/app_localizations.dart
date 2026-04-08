import 'package:flutter/widgets.dart';

import 'package:pinterest/core/constants/default_local_strings.dart';
import 'package:pinterest/core/utils/app_logger.dart';

/// Provides localized string lookup via `Localizations.of<AppLocalizations>`.
///
/// Strings are accessed via dot-notation key paths:
/// ```dart
/// appLocalizations.tr('general.retry')  // "Retry"
/// appLocalizations.tr('search.noResultsFor', params: {'query': 'cats'})
/// ```
class AppLocalizations {
  AppLocalizations(this._strings);

  Map<String, dynamic> _strings;

  /// Look up via [Localizations.of].
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Update the loaded strings (e.g. after language change).
  void updateStrings(Map<String, dynamic> strings) {
    _strings = strings;
  }

  /// Translate a dot-separated key path with optional placeholder params.
  ///
  /// Example:
  /// ```dart
  /// tr('general.retry')  →  "Retry"
  /// tr('profile.pinsSaved', params: {'count': '5'})  →  "5 Pins saved"
  /// ```
  String tr(String keyPath, {Map<String, dynamic>? params}) {
    final keys = keyPath.split('.');
    dynamic current = _strings;

    for (final key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        // Fallback to default English strings
        current = _resolveFallback(keys);
        break;
      }
    }

    var result = current?.toString() ?? keyPath;

    // Replace placeholders: {key} → value
    if (params != null) {
      params.forEach((key, value) {
        result = result.replaceAll('{$key}', value.toString());
      });
    }

    return result;
  }

  /// Resolve from DefaultLocaleStrings.english as fallback.
  dynamic _resolveFallback(List<String> keys) {
    dynamic current = DefaultLocaleStrings.english;
    for (final key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        AppLogger.warning(
          '⚠️ Missing translation key: ${keys.join('.')}',
        );
        return keys.last;
      }
    }
    return current;
  }
}

/// Delegate that provides [AppLocalizations] to the widget tree.
class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  AppLocalizationsDelegate()
      : _appLocalizations =
            AppLocalizations(DefaultLocaleStrings.english);

  final AppLocalizations _appLocalizations;

  /// Update the strings after a language change.
  void updateStrings(Map<String, dynamic> strings) {
    _appLocalizations.updateStrings(strings);
  }

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'te'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return _appLocalizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

/// Global accessor for the delegate — used to update strings at runtime.
AppLocalizationsDelegate? _globalDelegate;

AppLocalizationsDelegate getAppLocalizationsDelegate() {
  _globalDelegate ??= AppLocalizationsDelegate();
  return _globalDelegate!;
}
