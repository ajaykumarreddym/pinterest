import 'dart:convert';

import 'package:pinterest/core/base/base_exception.dart';
import 'package:pinterest/core/constants/storage_keys.dart';
import 'package:pinterest/core/services/storage/app_storage.dart';
import 'package:pinterest/features/home/data/models/photo_model.dart';

/// Local datasource for saving/retrieving bookmarked pins.
abstract class SavedPinsLocalDatasource {
  Future<void> savePin(PhotoModel photo);
  Future<void> unsavePin(int photoId);
  List<PhotoModel> getSavedPins();
  bool isPinSaved(int photoId);
}

class SavedPinsLocalDatasourceImpl implements SavedPinsLocalDatasource {
  const SavedPinsLocalDatasourceImpl({required this.storage});

  final AppStorage storage;

  List<PhotoModel> _readAll() {
    final cached = storage.getStringList(StorageKeys.savedPins);
    if (cached == null || cached.isEmpty) return [];
    return cached
        .map((s) => PhotoModel.fromJson(
              jsonDecode(s) as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<bool> _writeAll(List<PhotoModel> pins) {
    final jsonList = pins.map((p) => jsonEncode(p.toJson())).toList();
    return storage.setStringList(StorageKeys.savedPins, jsonList);
  }

  @override
  Future<void> savePin(PhotoModel photo) async {
    final pins = _readAll();
    if (pins.any((p) => p.id == photo.id)) return;
    pins.insert(0, photo);
    final success = await _writeAll(pins);
    if (!success) {
      throw const CacheException(message: 'Failed to save pin');
    }
  }

  @override
  Future<void> unsavePin(int photoId) async {
    final pins = _readAll();
    pins.removeWhere((p) => p.id == photoId);
    final success = await _writeAll(pins);
    if (!success) {
      throw const CacheException(message: 'Failed to unsave pin');
    }
  }

  @override
  List<PhotoModel> getSavedPins() => _readAll();

  @override
  bool isPinSaved(int photoId) {
    final pins = _readAll();
    return pins.any((p) => p.id == photoId);
  }
}
