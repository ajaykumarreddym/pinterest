import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:pinterest/features/home/domain/entities/photo.dart';

part 'photo_model.freezed.dart';
part 'photo_model.g.dart';

@freezed
class PhotoModel with _$PhotoModel {
  const PhotoModel._();

  const factory PhotoModel({
    required int id,
    required int width,
    required int height,
    required String url,
    required String photographer,
    @JsonKey(name: 'photographer_url') required String photographerUrl,
    @JsonKey(name: 'photographer_id') required int photographerId,
    @JsonKey(name: 'avg_color') required String avgColor,
    required PhotoSrcModel src,
    required bool liked,
    required String alt,
  }) = _PhotoModel;

  factory PhotoModel.fromJson(Map<String, dynamic> json) =>
      _$PhotoModelFromJson(json);

  Photo toEntity() => Photo(
        id: id,
        width: width,
        height: height,
        url: url,
        photographer: photographer,
        photographerUrl: photographerUrl,
        photographerId: photographerId,
        avgColor: avgColor,
        src: src.toEntity(),
        liked: liked,
        alt: alt,
      );
}

@freezed
class PhotoSrcModel with _$PhotoSrcModel {
  const PhotoSrcModel._();

  const factory PhotoSrcModel({
    required String original,
    required String large2x,
    required String large,
    required String medium,
    required String small,
    required String portrait,
    required String landscape,
    required String tiny,
  }) = _PhotoSrcModel;

  factory PhotoSrcModel.fromJson(Map<String, dynamic> json) =>
      _$PhotoSrcModelFromJson(json);

  PhotoSrc toEntity() => PhotoSrc(
        original: original,
        large2x: large2x,
        large: large,
        medium: medium,
        small: small,
        portrait: portrait,
        landscape: landscape,
        tiny: tiny,
      );
}

@freezed
class PexelsResponse with _$PexelsResponse {
  const factory PexelsResponse({
    required int page,
    @JsonKey(name: 'per_page') required int perPage,
    @JsonKey(name: 'total_results') required int totalResults,
    @JsonKey(name: 'next_page') String? nextPage,
    required List<PhotoModel> photos,
  }) = _PexelsResponse;

  factory PexelsResponse.fromJson(Map<String, dynamic> json) =>
      _$PexelsResponseFromJson(json);
}
