import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/core/di/injection.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/pin_detail/data/datasources/pin_detail_remote_datasource.dart';
import 'package:pinterest/features/pin_detail/data/repositories/pin_detail_repository_impl.dart';
import 'package:pinterest/features/pin_detail/domain/repositories/pin_detail_repository.dart';
import 'package:pinterest/features/pin_detail/domain/usecases/get_photo_by_id_usecase.dart';

// Datasource
final pinDetailRemoteDatasourceProvider =
    Provider<PinDetailRemoteDatasource>((ref) {
  return PinDetailRemoteDatasourceImpl(apiClient: ref.read(apiClientProvider));
});

// Repository
final pinDetailRepositoryProvider = Provider<PinDetailRepository>((ref) {
  return PinDetailRepositoryImpl(
    remoteDatasource: ref.read(pinDetailRemoteDatasourceProvider),
  );
});

// UseCase
final getPhotoByIdUseCaseProvider = Provider<GetPhotoByIdUseCase>((ref) {
  return GetPhotoByIdUseCase(ref.read(pinDetailRepositoryProvider));
});

// Photo detail by ID (family provider for different pin IDs)
final pinDetailProvider =
    FutureProvider.family<Photo, int>((ref, id) async {
  final useCase = ref.read(getPhotoByIdUseCaseProvider);
  final result = await useCase(GetPhotoByIdParams(id: id));
  return result.fold(
    (failure) => throw failure,
    (photo) => photo,
  );
});
