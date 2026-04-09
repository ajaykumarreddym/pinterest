import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation.freezed.dart';

/// A chat conversation in the inbox.
@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String participantName,
    required String participantAvatar,
    required String lastMessage,
    required DateTime lastMessageTime,
    required bool isRead,
    @Default(0) int unreadCount,
    @Default(false) bool isPinShare,
    String? sharedPinThumbnail,
  }) = _Conversation;
}
