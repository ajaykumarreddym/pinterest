import 'package:freezed_annotation/freezed_annotation.dart';

part 'collage.freezed.dart';
part 'collage.g.dart';

/// A collage composed of multiple images arranged together.
@freezed
class Collage with _$Collage {
  const factory Collage({
    required String id,
    required String title,
    required List<String> imagePaths,
    required DateTime createdAt,
  }) = _Collage;

  factory Collage.fromJson(Map<String, dynamic> json) =>
      _$CollageFromJson(json);
}
