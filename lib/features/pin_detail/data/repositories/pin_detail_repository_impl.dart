import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_exception.dart';
import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/pin_detail/data/datasources/pin_detail_remote_datasource.dart';
import 'package:pinterest/features/pin_detail/domain/repositories/pin_detail_repository.dart';

class PinDetailRepositoryImpl implements PinDetailRepository {
  const PinDetailRepositoryImpl({required this.remoteDatasource});

  final PinDetailRemoteDatasource remoteDatasource;

  @override
  Future<Either<Failure, Photo>> getPhotoById({required int id}) async {
    try {
      final model = await remoteDatasource.getPhotoById(id: id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
