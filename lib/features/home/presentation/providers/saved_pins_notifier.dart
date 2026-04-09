import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/core/utils/app_logger.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/home/presentation/providers/saved_pins_providers.dart';

/// Manages saved/bookmarked pins state.
class SavedPinsNotifier extends AsyncNotifier<List<Photo>> {
  @override
  Future<List<Photo>> build() async {
    AppLogger.info('📌 SavedPinsNotifier.build() — loading saved pins');
    final repo = ref.read(savedPinsRepositoryProvider);
    final result = await repo.getSavedPins();
    return result.fold(
      (failure) {
        AppLogger.error('❌ Failed to load saved pins: ${failure.message}');
        return [];
      },
      (pins) {
        AppLogger.info('✅ Loaded ${pins.length} saved pins');
        return pins;
      },
    );
  }

  /// Toggle save/unsave a pin. Returns true if now saved, false if unsaved.
  Future<bool> togglePin(Photo photo) async {
    final repo = ref.read(savedPinsRepositoryProvider);
    final isSaved = repo.isPinSaved(photo.id);

    if (isSaved) {
      final result = await repo.unsavePin(photo.id);
      result.fold(
        (failure) =>
            AppLogger.error('❌ Failed to unsave pin: ${failure.message}'),
        (_) => AppLogger.info('📌 Pin ${photo.id} unsaved'),
      );
    } else {
      final result = await repo.savePin(photo);
      result.fold(
        (failure) =>
            AppLogger.error('❌ Failed to save pin: ${failure.message}'),
        (_) => AppLogger.info('📌 Pin ${photo.id} saved'),
      );
    }

    // Refresh state
    ref.invalidateSelf();
    return !isSaved;
  }

  /// Check if a pin is saved (synchronous).
  bool isPinSaved(int photoId) {
    return ref.read(savedPinsRepositoryProvider).isPinSaved(photoId);
  }
}
