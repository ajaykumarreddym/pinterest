import 'package:pinterest/features/search/domain/entities/search_video.dart';

/// Model for a Pexels video response.
class VideoModel {
  const VideoModel({
    required this.id,
    required this.width,
    required this.height,
    required this.url,
    required this.image,
    required this.duration,
    required this.user,
    required this.videoFiles,
  });

  final int id;
  final int width;
  final int height;
  final String url;
  final String image;
  final int duration;
  final VideoUserModel user;
  final List<VideoFileModel> videoFiles;

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as int,
      width: json['width'] as int,
      height: json['height'] as int,
      url: json['url'] as String? ?? '',
      image: json['image'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      user: VideoUserModel.fromJson(
        json['user'] as Map<String, dynamic>? ?? {},
      ),
      videoFiles: (json['video_files'] as List<dynamic>?)
              ?.map(
                (f) => VideoFileModel.fromJson(f as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  SearchVideo toEntity() => SearchVideo(
        id: id,
        width: width,
        height: height,
        url: url,
        image: image,
        duration: duration,
        userName: user.name,
        userUrl: user.url,
        videoFiles: videoFiles.map((f) => f.toEntity()).toList(),
      );
}

/// Model for a Pexels video user.
class VideoUserModel {
  const VideoUserModel({
    required this.id,
    required this.name,
    required this.url,
  });

  final int id;
  final String name;
  final String url;

  factory VideoUserModel.fromJson(Map<String, dynamic> json) {
    return VideoUserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}

/// Model for a single video file variant from Pexels.
class VideoFileModel {
  const VideoFileModel({
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

  factory VideoFileModel.fromJson(Map<String, dynamic> json) {
    return VideoFileModel(
      id: json['id'] as int? ?? 0,
      quality: json['quality'] as String? ?? '',
      fileType: json['file_type'] as String? ?? '',
      width: json['width'] as int?,
      height: json['height'] as int?,
      link: json['link'] as String? ?? '',
    );
  }

  VideoFile toEntity() => VideoFile(
        id: id,
        quality: quality,
        fileType: fileType,
        width: width,
        height: height,
        link: link,
      );
}

/// Response wrapper for Pexels Video search API.
class PexelsVideoResponse {
  const PexelsVideoResponse({
    required this.page,
    required this.perPage,
    required this.totalResults,
    required this.videos,
  });

  final int page;
  final int perPage;
  final int totalResults;
  final List<VideoModel> videos;

  factory PexelsVideoResponse.fromJson(Map<String, dynamic> json) {
    return PexelsVideoResponse(
      page: json['page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 15,
      totalResults: json['total_results'] as int? ?? 0,
      videos: (json['videos'] as List<dynamic>?)
              ?.map(
                (v) => VideoModel.fromJson(v as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}
