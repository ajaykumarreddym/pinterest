import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';

/// Repository contract for saved/bookmarked pins.
abstract class SavedPinsRepository {
  /// Save a pin to local storage.
  Future<Either<Failure, void>> savePin(Photo photo);

  /// Remove a saved pin.
  Future<Either<Failure, void>> unsavePin(int photoId);

  /// Get all saved pins.
  Future<Either<Failure, List<Photo>>> getSavedPins();

  /// Check if a pin is saved.
  bool isPinSaved(int photoId);
}
