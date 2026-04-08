import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo.freezed.dart';

/// Domain entity for a photo/pin.
@freezed
class Photo with _$Photo {
  const factory Photo({
    required int id,
    required int width,
    required int height,
    required String url,
    required String photographer,
    required String photographerUrl,
    required int photographerId,
    required String avgColor,
    required PhotoSrc src,
    required bool liked,
    required String alt,
  }) = _Photo;
}

@freezed
class PhotoSrc with _$PhotoSrc {
  const factory PhotoSrc({
    required String original,
    required String large2x,
    required String large,
    required String medium,
    required String small,
    required String portrait,
    required String landscape,
    required String tiny,
  }) = _PhotoSrc;
}
