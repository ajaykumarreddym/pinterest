import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:pinterest/features/messages/domain/entities/conversation.dart';

part 'conversation_model.freezed.dart';
part 'conversation_model.g.dart';

/// JSON-serializable model for [Conversation].
@freezed
class ConversationModel with _$ConversationModel {
  const ConversationModel._();

  const factory ConversationModel({
    required String id,
    required String participantName,
    required String participantAvatar,
    required String lastMessage,
    required int lastMessageTimeMs,
    required bool isRead,
    @Default(0) int unreadCount,
    @Default(false) bool isPinShare,
    String? sharedPinThumbnail,
  }) = _ConversationModel;

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  /// Convert to domain entity.
  Conversation toEntity() => Conversation(
        id: id,
        participantName: participantName,
        participantAvatar: participantAvatar,
        lastMessage: lastMessage,
        lastMessageTime:
            DateTime.fromMillisecondsSinceEpoch(lastMessageTimeMs),
        isRead: isRead,
        unreadCount: unreadCount,
        isPinShare: isPinShare,
        sharedPinThumbnail: sharedPinThumbnail,
      );

  /// Create from domain entity.
  factory ConversationModel.fromEntity(Conversation entity) =>
      ConversationModel(
        id: entity.id,
        participantName: entity.participantName,
        participantAvatar: entity.participantAvatar,
        lastMessage: entity.lastMessage,
        lastMessageTimeMs: entity.lastMessageTime.millisecondsSinceEpoch,
        isRead: entity.isRead,
        unreadCount: entity.unreadCount,
        isPinShare: entity.isPinShare,
        sharedPinThumbnail: entity.sharedPinThumbnail,
      );
}
