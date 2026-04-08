import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/core/utils/app_logger.dart';
import 'package:pinterest/features/localization/data/datasources/localization_local_datasource.dart';
import 'package:pinterest/features/localization/data/datasources/localization_remote_datasource.dart';
import 'package:pinterest/features/localization/domain/entities/language_data.dart';
import 'package:pinterest/features/localization/domain/repositories/localization_repository.dart';

class LocalizationRepositoryImpl implements LocalizationRepository {
  LocalizationRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  final LocalizationRemoteDatasource remoteDatasource;
  final LocalizationLocalDatasource localDatasource;

  @override
  Future<Either<Failure, LanguageData>> getLanguageData(
    SupportedLanguage language,
  ) async {
    try {
      final data = await remoteDatasource.getLanguageData(language);
      // Cache for offline access
      await localDatasource.cacheLanguageStrings(data.strings);
      await localDatasource.setCurrentLanguageCode(language.code);
      return Right(data);
    } catch (e) {
      AppLogger.error('Failed to load language data', error: e);
      // Try cached strings as fallback
      final cached = localDatasource.getCachedLanguageStrings();
      if (cached != null) {
        AppLogger.info('📦 Using cached language strings as fallback');
        return Right(LanguageData(language: language, strings: cached));
      }
      return Left(ServerFailure(message: 'Failed to load language: ${e.toString()}'));
    }
  }

  @override
  String? getCurrentLanguageCode() {
    return localDatasource.getCurrentLanguageCode();
  }

  @override
  Future<void> setCurrentLanguageCode(String code) {
    return localDatasource.setCurrentLanguageCode(code);
  }

  @override
  Future<void> cacheLanguageStrings(Map<String, dynamic> strings) {
    return localDatasource.cacheLanguageStrings(strings);
  }

  @override
  Map<String, dynamic>? getCachedLanguageStrings() {
    return localDatasource.getCachedLanguageStrings();
  }
}
