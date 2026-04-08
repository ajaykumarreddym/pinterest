import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';

/// Repository contract for pin detail operations.
abstract class PinDetailRepository {
  Future<Either<Failure, Photo>> getPhotoById({required int id});
}
