import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:pinterest/core/utils/app_logger.dart';

final shareServiceProvider = Provider<ShareService>((ref) {
  return const ShareService();
});

/// Handles sharing pins via the native share sheet.
class ShareService {
  const ShareService();

  /// Share a pin URL with optional text.
  Future<void> shareUrl({
    required String url,
    String? text,
  }) async {
    try {
      final shareText = text != null ? '$text\n$url' : url;
      await SharePlus.instance.share(ShareParams(text: shareText));
      AppLogger.info('📤 Shared URL: $url');
    } catch (e) {
      AppLogger.error('❌ Share failed: $e');
    }
  }

  /// Share a pin image downloaded from [imageUrl].
  Future<void> shareImage({
    required String imageUrl,
    String? text,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'pinterest_share_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${tempDir.path}/$fileName';

      await Dio().download(imageUrl, filePath);

      await SharePlus.instance.share(
        ShareParams(
          text: text,
          files: [XFile(filePath)],
        ),
      );

      AppLogger.info('📤 Shared image from: $imageUrl');

      // Clean up temp file
      final tempFile = File(filePath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (e) {
      AppLogger.error('❌ Share image failed: $e');
    }
  }
}
