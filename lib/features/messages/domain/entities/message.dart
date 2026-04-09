import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';

/// A single chat message within a conversation.
@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String content,
    required DateTime timestamp,
    required MessageType type,
    @Default(false) bool isMe,
    String? imageUrl,
    String? pinId,
    String? pinThumbnail,
  }) = _Message;
}

enum MessageType {
  text,
  image,
  pinShare,
}
