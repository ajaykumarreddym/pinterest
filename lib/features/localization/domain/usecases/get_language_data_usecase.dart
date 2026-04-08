import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/core/base/base_usecase.dart';
import 'package:pinterest/features/localization/domain/entities/language_data.dart';
import 'package:pinterest/features/localization/domain/repositories/localization_repository.dart';

class GetLanguageDataUseCase
    extends BaseUseCase<SupportedLanguage, LanguageData> {
  GetLanguageDataUseCase(this._repository);

  final LocalizationRepository _repository;

  @override
  Future<Either<Failure, LanguageData>> call(SupportedLanguage params) {
    return _repository.getLanguageData(params);
  }
}
