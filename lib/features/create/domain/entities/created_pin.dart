import 'package:freezed_annotation/freezed_annotation.dart';

part 'created_pin.freezed.dart';
part 'created_pin.g.dart';

/// A pin created by the user from their gallery.
@freezed
class CreatedPin with _$CreatedPin {
  const factory CreatedPin({
    required String id,
    required String imagePath,
    required String title,
    @Default('') String description,
    @Default('') String boardId,
    required DateTime createdAt,
  }) = _CreatedPin;

  factory CreatedPin.fromJson(Map<String, dynamic> json) =>
      _$CreatedPinFromJson(json);
}
