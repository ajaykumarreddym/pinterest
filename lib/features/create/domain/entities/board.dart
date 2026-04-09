import 'package:freezed_annotation/freezed_annotation.dart';

part 'board.freezed.dart';
part 'board.g.dart';

/// A board that groups related pins together.
@freezed
class Board with _$Board {
  const factory Board({
    required String id,
    required String name,
    @Default('') String description,
    @Default('') String coverImagePath,
    @Default([]) List<String> pinIds,
    required DateTime createdAt,
  }) = _Board;

  factory Board.fromJson(Map<String, dynamic> json) => _$BoardFromJson(json);
}
