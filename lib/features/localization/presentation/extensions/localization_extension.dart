import 'package:flutter/widgets.dart';

import 'package:pinterest/features/localization/presentation/app_localizations.dart';

/// Extension on [BuildContext] for easy string translation access.
///
/// Usage:
/// ```dart
/// Text(context.tr('general.retry'))
/// Text(context.tr('profile.pinsSaved', params: {'count': '5'}))
/// ```
extension LocalizationExtension on BuildContext {
  /// Translate a dot-separated key path.
  String tr(String keyPath, {Map<String, dynamic>? params}) {
    final l10n = AppLocalizations.of(this);
    if (l10n == null) {
      // Fallback when Localizations not yet available (e.g. during init)
      return keyPath;
    }
    return l10n.tr(keyPath, params: params);
  }
}
