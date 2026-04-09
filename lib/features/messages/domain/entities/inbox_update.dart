import 'package:freezed_annotation/freezed_annotation.dart';

part 'inbox_update.freezed.dart';

/// A notification/update item in the inbox Updates tab.
@freezed
class InboxUpdate with _$InboxUpdate {
  const factory InboxUpdate({
    required String id,
    required String title,
    required String body,
    required String avatarUrl,
    required DateTime timestamp,
    required InboxUpdateType type,
    required bool isRead,
    String? thumbnailUrl,
    String? actionUrl,
  }) = _InboxUpdate;
}

/// Types of inbox updates (matching Pinterest patterns).
enum InboxUpdateType {
  pinRecommendation,
  boardInvite,
  follow,
  like,
  comment,
  mention,
  trending,
}
