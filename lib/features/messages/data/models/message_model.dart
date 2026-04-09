import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:pinterest/features/messages/domain/entities/message.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

/// JSON-serializable model for [Message].
@freezed
class MessageModel with _$MessageModel {
  const MessageModel._();

  const factory MessageModel({
    required String id,
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String content,
    required int timestampMs,
    required String type,
    @Default(false) bool isMe,
    String? imageUrl,
    String? pinId,
    String? pinThumbnail,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  /// Convert to domain entity.
  Message toEntity() => Message(
        id: id,
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        senderAvatar: senderAvatar,
        content: content,
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMs),
        type: _parseType(type),
        isMe: isMe,
        imageUrl: imageUrl,
        pinId: pinId,
        pinThumbnail: pinThumbnail,
      );

  /// Create from domain entity.
  factory MessageModel.fromEntity(Message entity) => MessageModel(
        id: entity.id,
        conversationId: entity.conversationId,
        senderId: entity.senderId,
        senderName: entity.senderName,
        senderAvatar: entity.senderAvatar,
        content: entity.content,
        timestampMs: entity.timestamp.millisecondsSinceEpoch,
        type: entity.type.name,
        isMe: entity.isMe,
        imageUrl: entity.imageUrl,
        pinId: entity.pinId,
        pinThumbnail: entity.pinThumbnail,
      );

  static MessageType _parseType(String type) {
    return MessageType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => MessageType.text,
    );
  }
}
