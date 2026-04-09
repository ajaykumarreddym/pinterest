import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:pinterest/features/messages/domain/entities/inbox_update.dart';

part 'inbox_update_model.freezed.dart';
part 'inbox_update_model.g.dart';

/// JSON-serializable model for [InboxUpdate].
@freezed
class InboxUpdateModel with _$InboxUpdateModel {
  const InboxUpdateModel._();

  const factory InboxUpdateModel({
    required String id,
    required String title,
    required String body,
    required String avatarUrl,
    required int timestampMs,
    required String type,
    required bool isRead,
    String? thumbnailUrl,
    String? actionUrl,
  }) = _InboxUpdateModel;

  factory InboxUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$InboxUpdateModelFromJson(json);

  /// Convert to domain entity.
  InboxUpdate toEntity() => InboxUpdate(
        id: id,
        title: title,
        body: body,
        avatarUrl: avatarUrl,
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMs),
        type: _parseUpdateType(type),
        isRead: isRead,
        thumbnailUrl: thumbnailUrl,
        actionUrl: actionUrl,
      );

  /// Create from domain entity.
  factory InboxUpdateModel.fromEntity(InboxUpdate entity) => InboxUpdateModel(
        id: entity.id,
        title: entity.title,
        body: entity.body,
        avatarUrl: entity.avatarUrl,
        timestampMs: entity.timestamp.millisecondsSinceEpoch,
        type: entity.type.name,
        isRead: entity.isRead,
        thumbnailUrl: entity.thumbnailUrl,
        actionUrl: entity.actionUrl,
      );

  static InboxUpdateType _parseUpdateType(String type) {
    return InboxUpdateType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => InboxUpdateType.pinRecommendation,
    );
  }
}
