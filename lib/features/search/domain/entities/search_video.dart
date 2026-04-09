/// Domain entity for a Pexels video result.
class SearchVideo {
  const SearchVideo({
    required this.id,
    required this.width,
    required this.height,
    required this.url,
    required this.image,
    required this.duration,
    required this.userName,
    required this.userUrl,
    required this.videoFiles,
  });

  final int id;
  final int width;
  final int height;
  final String url;
  final String image;
  final int duration;
  final String userName;
  final String userUrl;
  final List<VideoFile> videoFiles;

  /// Returns the best HD video file URL, falling back to SD.
  String? get bestVideoUrl {
    // Prefer HD quality
    final hd = videoFiles.where(
      (f) => f.quality == 'hd' && f.fileType == 'video/mp4',
    );
    if (hd.isNotEmpty) return hd.first.link;

    // Fallback to SD
    final sd = videoFiles.where(
      (f) => f.quality == 'sd' && f.fileType == 'video/mp4',
    );
    if (sd.isNotEmpty) return sd.first.link;

    // Any mp4
    final any = videoFiles.where((f) => f.fileType == 'video/mp4');
    if (any.isNotEmpty) return any.first.link;

    return null;
  }
}

/// A single video file variant from Pexels.
class VideoFile {
  const VideoFile({
    required this.id,
    required this.quality,
    required this.fileType,
    required this.width,
    required this.height,
    required this.link,
  });

  final int id;
  final String quality;
  final String fileType;
  final int? width;
  final int? height;
  final String link;
}
