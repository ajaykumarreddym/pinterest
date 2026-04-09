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

  static const _separator = '|';

  // ── Reported ──

  Set<int> _reportedIds() {
    final list = storage.getStringList(StorageKeys.reportedPinIds);
    if (list == null) return {};
    return list.map((e) => int.parse(e.split(_separator).first)).toSet();
  }

  /// Returns a map of reported pin ID → image URL.
  Map<int, String> getReportedPins() {
    final list = storage.getStringList(StorageKeys.reportedPinIds);
    if (list == null) return {};
    final map = <int, String>{};
    for (final entry in list) {
      final parts = entry.split(_separator);
      final id = int.parse(parts.first);
      final imageUrl = parts.length > 1 ? parts.sublist(1).join(_separator) : '';
      map[id] = imageUrl;
    }
    return map;
  }

  Future<void> reportPin(int photoId, {String imageUrl = ''}) async {
    final pins = getReportedPins();
    pins[photoId] = imageUrl;
    await storage.setStringList(
      StorageKeys.reportedPinIds,
      pins.entries.map((e) => '${e.key}$_separator${e.value}').toList(),
    );
    AppLogger.info('🚫 Pin $photoId reported');
  }

  bool isReported(int photoId) => _reportedIds().contains(photoId);

  Set<int> getReportedIds() => _reportedIds();

  // ── Hidden ("not interested") ──

  Set<int> _hiddenIds() {
    final list = storage.getStringList(StorageKeys.hiddenPinIds);
    if (list == null) return {};
    return list.map((e) => int.parse(e.split(_separator).first)).toSet();
  }

  /// Returns a map of hidden pin ID → image URL.
  Map<int, String> getHiddenPins() {
    final list = storage.getStringList(StorageKeys.hiddenPinIds);
    if (list == null) return {};
    final map = <int, String>{};
    for (final entry in list) {
      final parts = entry.split(_separator);
      final id = int.parse(parts.first);
      final imageUrl = parts.length > 1 ? parts.sublist(1).join(_separator) : '';
      map[id] = imageUrl;
    }
    return map;
  }

  Future<void> hidePin(int photoId, {String imageUrl = ''}) async {
    final pins = getHiddenPins();
    pins[photoId] = imageUrl;
    await storage.setStringList(
      StorageKeys.hiddenPinIds,
      pins.entries.map((e) => '${e.key}$_separator${e.value}').toList(),
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
