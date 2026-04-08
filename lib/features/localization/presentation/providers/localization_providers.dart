import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/core/constants/default_local_strings.dart';
import 'package:pinterest/core/di/injection.dart';
import 'package:pinterest/core/utils/app_logger.dart';
import 'package:pinterest/features/localization/data/datasources/localization_local_datasource.dart';
import 'package:pinterest/features/localization/data/datasources/localization_remote_datasource.dart';
import 'package:pinterest/features/localization/data/repositories/localization_repository_impl.dart';
import 'package:pinterest/features/localization/domain/entities/language_data.dart';
import 'package:pinterest/features/localization/domain/repositories/localization_repository.dart';
import 'package:pinterest/features/localization/domain/usecases/get_language_data_usecase.dart';
import 'package:pinterest/features/localization/presentation/app_localizations.dart';

// ─── Datasources ────────────────────────────────────────────────
final localizationRemoteDatasourceProvider =
    Provider<LocalizationRemoteDatasource>((ref) {
  return LocalizationRemoteDatasourceImpl();
});

final localizationLocalDatasourceProvider =
    Provider<LocalizationLocalDatasource>((ref) {
  return LocalizationLocalDatasourceImpl(
    storage: ref.read(appStorageProvider),
  );
});

// ─── Repository ─────────────────────────────────────────────────
final localizationRepositoryProvider =
    Provider<LocalizationRepository>((ref) {
  return LocalizationRepositoryImpl(
    remoteDatasource: ref.read(localizationRemoteDatasourceProvider),
    localDatasource: ref.read(localizationLocalDatasourceProvider),
  );
});

// ─── Use Case ───────────────────────────────────────────────────
final getLanguageDataUseCaseProvider =
    Provider<GetLanguageDataUseCase>((ref) {
  return GetLanguageDataUseCase(ref.read(localizationRepositoryProvider));
});

// ─── State ──────────────────────────────────────────────────────

/// Holds the current locale for the app.
final appLocaleProvider = StateProvider<Locale>((ref) {
  final repo = ref.read(localizationRepositoryProvider);
  final cached = repo.getCurrentLanguageCode();
  final lang = cached != null
      ? SupportedLanguage.fromCode(cached)
      : SupportedLanguage.english;
  return lang.locale;
});

/// Main localization notifier — manages loading and switching languages.
class LocalizationNotifier extends AsyncNotifier<LanguageData> {
  @override
  Future<LanguageData> build() async {
    final repo = ref.read(localizationRepositoryProvider);
    final cachedCode = repo.getCurrentLanguageCode();
    final language = cachedCode != null
        ? SupportedLanguage.fromCode(cachedCode)
        : SupportedLanguage.english;

    AppLogger.info('🌍 Localization init — language: ${language.displayName}');

    // Try cached strings first for instant load
    final cachedStrings = repo.getCachedLanguageStrings();
    if (cachedStrings != null) {
      AppLogger.info('📦 Using cached strings for ${language.code}');
      final data = LanguageData(language: language, strings: cachedStrings);
      _applyStrings(data);
      return data;
    }

    // Load from assets
    return _loadLanguage(language);
  }

  /// Change the app language.
  Future<void> changeLanguage(SupportedLanguage language) async {
    AppLogger.info('🔄 Changing language to ${language.displayName}');
    state = const AsyncLoading();

    final data = await _loadLanguage(language);
    state = AsyncData(data);
  }

  Future<LanguageData> _loadLanguage(SupportedLanguage language) async {
    final useCase = ref.read(getLanguageDataUseCaseProvider);
    final result = await useCase(language);

    return result.fold(
      (failure) {
        AppLogger.error('❌ Language load failed: ${failure.message}');
        // Use default English as ultimate fallback
        final fallback = LanguageData(
          language: SupportedLanguage.english,
          strings: DefaultLocaleStrings.english,
        );
        _applyStrings(fallback);
        return fallback;
      },
      (data) {
        _applyStrings(data);
        return data;
      },
    );
  }

  void _applyStrings(LanguageData data) {
    // Update the delegate so context.tr() picks up new strings
    getAppLocalizationsDelegate().updateStrings(data.strings);
    // Defer locale update to avoid modifying another provider during build
    Future.microtask(() {
      ref.read(appLocaleProvider.notifier).state = data.language.locale;
    });
    AppLogger.info(
      '✅ Applied ${data.language.displayName} strings',
    );
  }
}

final localizationProvider =
    AsyncNotifierProvider<LocalizationNotifier, LanguageData>(
  LocalizationNotifier.new,
);
