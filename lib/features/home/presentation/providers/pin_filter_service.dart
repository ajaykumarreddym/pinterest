import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/core/constants/storage_keys.dart';
import 'package:pinterest/core/di/injection.dart';
import 'package:pinterest/core/services/storage/app_storage.dart';
import 'package:pinterest/core/utils/app_logger.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';

final pinFilterServiceProvider = Provider<PinFilterService>((ref) {
  return PinFilterService(storage: ref.read(appStorageProvider));
});

/// Manages reported and hidden ("not interested") pin IDs.
/// Filters them out of any photo list before display.
class PinFilterService {
  const PinFilterService({required this.storage});

  final AppStorage storage;

  // ── Reported ──

  Set<int> _reportedIds() {
    final list = storage.getStringList(StorageKeys.reportedPinIds);
    if (list == null) return {};
    return list.map(int.parse).toSet();
  }

  Future<void> reportPin(int photoId) async {
    final ids = _reportedIds();
    ids.add(photoId);
    await storage.setStringList(
      StorageKeys.reportedPinIds,
      ids.map((e) => e.toString()).toList(),
    );
    AppLogger.info('🚫 Pin $photoId reported');
  }

  bool isReported(int photoId) => _reportedIds().contains(photoId);

  Set<int> getReportedIds() => _reportedIds();

  // ── Hidden ("not interested") ──

  Set<int> _hiddenIds() {
    final list = storage.getStringList(StorageKeys.hiddenPinIds);
    if (list == null) return {};
    return list.map(int.parse).toSet();
  }

  Future<void> hidePin(int photoId) async {
    final ids = _hiddenIds();
    ids.add(photoId);
    await storage.setStringList(
      StorageKeys.hiddenPinIds,
      ids.map((e) => e.toString()).toList(),
    );
    AppLogger.info('👁️ Pin $photoId hidden (not interested)');
  }

  bool isHidden(int photoId) => _hiddenIds().contains(photoId);

  Set<int> getHiddenIds() => _hiddenIds();

  // ── Filter ──

  /// Removes reported and hidden pins from a list.
  List<Photo> filterPhotos(List<Photo> photos) {
    final reported = _reportedIds();
    final hidden = _hiddenIds();
    final excluded = reported.union(hidden);
    if (excluded.isEmpty) return photos;
    return photos.where((p) => !excluded.contains(p.id)).toList();
  }
}
