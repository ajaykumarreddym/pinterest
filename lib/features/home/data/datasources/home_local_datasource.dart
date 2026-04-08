import 'dart:convert';

import 'package:pinterest/core/base/base_exception.dart';
import 'package:pinterest/core/constants/storage_keys.dart';
import 'package:pinterest/core/services/storage/app_storage.dart';
import 'package:pinterest/features/home/data/models/photo_model.dart';

/// Local cache data source for home feed photos.
abstract class HomeLocalDatasource {
  Future<void> cacheCuratedPhotos(List<PhotoModel> photos);
  Future<List<PhotoModel>> getCachedPhotos();
  Future<void> clearCache();
}

class HomeLocalDatasourceImpl implements HomeLocalDatasource {
  const HomeLocalDatasourceImpl({required this.storage});

  final AppStorage storage;

  @override
  Future<void> cacheCuratedPhotos(List<PhotoModel> photos) async {
    final jsonList = photos.map((p) => jsonEncode(p.toJson())).toList();
    await storage.setStringList(StorageKeys.cachedPhotos, jsonList);
  }

  @override
  Future<List<PhotoModel>> getCachedPhotos() {
    final cached = storage.getStringList(StorageKeys.cachedPhotos);
    if (cached == null || cached.isEmpty) {
      throw const CacheException(message: 'No cached photos found');
    }
    return Future.value(
      cached
          .map((s) => PhotoModel.fromJson(
                jsonDecode(s) as Map<String, dynamic>,
              ))
          .toList(),
    );
  }

  @override
  Future<void> clearCache() async {
    await storage.remove(StorageKeys.cachedPhotos);
  }
}
