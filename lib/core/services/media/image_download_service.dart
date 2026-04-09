import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pinterest/core/services/permissions/permission_service.dart';
import 'package:pinterest/core/utils/app_logger.dart';

final imageDownloadServiceProvider = Provider<ImageDownloadService>((ref) {
  return ImageDownloadService(
    permissionService: ref.read(permissionServiceProvider),
  );
});

/// Downloads images from URL and saves to device gallery.
class ImageDownloadService {
  const ImageDownloadService({required this.permissionService});

  final PermissionService permissionService;

  /// Downloads image from [url] and saves to gallery.
  /// Returns `true` on success, `false` on failure or denied permission.
  Future<bool> downloadAndSaveToGallery(
    String url, {
    String? albumName,
  }) async {
    try {
      // Request permission
      final granted = await permissionService.requestPhotosPermission();
      if (!granted) {
        AppLogger.warning('⬇️ Download aborted — permission denied');
        return false;
      }

      // Download to temp directory
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'pinterest_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${tempDir.path}/$fileName';

      AppLogger.info('⬇️ Downloading image to: $filePath');
      await Dio().download(url, filePath);

      // Save to gallery
      await Gal.putImage(filePath, album: albumName ?? 'Pinterest');
      AppLogger.info('✅ Image saved to gallery');

      // Clean up temp file
      final tempFile = File(filePath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      return true;
    } catch (e) {
      AppLogger.error('❌ Image download failed: $e');
      return false;
    }
  }
}
