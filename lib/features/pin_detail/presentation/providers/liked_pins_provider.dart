import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/core/constants/storage_keys.dart';
import 'package:pinterest/core/di/injection.dart';
import 'package:pinterest/core/services/storage/app_storage.dart';

/// Manages liked pin IDs in local storage.
class LikedPinsNotifier extends Notifier<Set<int>> {
  late final AppStorage _storage;

  @override
  Set<int> build() {
    _storage = ref.read(appStorageProvider);
    final list = _storage.getStringList(StorageKeys.likedPinIds);
    if (list == null) return {};
    return list.map(int.parse).toSet();
  }

  Future<void> toggleLike(int photoId) async {
    final ids = Set<int>.from(state);
    if (ids.contains(photoId)) {
      ids.remove(photoId);
    } else {
      ids.add(photoId);
    }
    await _storage.setStringList(
      StorageKeys.likedPinIds,
      ids.map((e) => e.toString()).toList(),
    );
    state = ids;
  }

  bool isLiked(int photoId) => state.contains(photoId);
}

final likedPinsProvider =
    NotifierProvider<LikedPinsNotifier, Set<int>>(LikedPinsNotifier.new);

/// Quick check if a specific pin is liked.
final isPinLikedProvider = Provider.family<bool, int>((ref, photoId) {
  final likedIds = ref.watch(likedPinsProvider);
  return likedIds.contains(photoId);
});
