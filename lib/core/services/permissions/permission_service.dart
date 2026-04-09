import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:pinterest/core/utils/app_logger.dart';

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return const PermissionService();
});

/// Handles runtime permission requests.
class PermissionService {
  const PermissionService();

  /// Request photo/storage permission for saving images.
  /// Returns `true` if granted.
  Future<bool> requestPhotosPermission() async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      // Android 13+ uses granular media permissions.
      final sdkInt = int.tryParse(
            Platform.version.split('.').first,
          ) ??
          0;
      if (sdkInt >= 33) {
        status = await Permission.photos.request();
      } else {
        status = await Permission.storage.request();
      }
    } else if (Platform.isIOS) {
      status = await Permission.photosAddOnly.request();
    } else {
      // Desktop — no permission needed.
      return true;
    }

    AppLogger.info('📷 Photo permission status: $status');

    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied) {
      AppLogger.warning('📷 Permission permanently denied — open settings');
      await openAppSettings();
      return false;
    }

    return false;
  }
}
