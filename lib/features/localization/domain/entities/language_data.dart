import 'dart:ui';

/// Supported app languages.
enum SupportedLanguage {
  english('en', 'English'),
  hindi('hi', 'हिन्दी'),
  telugu('te', 'తెలుగు');

  const SupportedLanguage(this.code, this.displayName);

  final String code;
  final String displayName;

  Locale get locale => Locale(code);

  static SupportedLanguage fromCode(String code) {
    return SupportedLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => SupportedLanguage.english,
    );
  }
}

/// Holds the loaded language data.
class LanguageData {
  const LanguageData({
    required this.language,
    required this.strings,
  });

  final SupportedLanguage language;
  final Map<String, dynamic> strings;
}
