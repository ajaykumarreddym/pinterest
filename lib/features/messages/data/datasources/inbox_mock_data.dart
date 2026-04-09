import 'package:pinterest/features/messages/data/models/conversation_model.dart';
import 'package:pinterest/features/messages/data/models/inbox_update_model.dart';
import 'package:pinterest/features/messages/data/models/message_model.dart';

/// Generates mock inbox data for first-time use.
class InboxMockDataGenerator {
  const InboxMockDataGenerator._();

  static List<ConversationModel> generateConversations() {
    final now = DateTime.now();
    return [
      ConversationModel(
        id: 'conv_1',
        participantName: 'Sarah Chen',
        participantAvatar: 'https://i.pravatar.cc/150?img=1',
        lastMessage: 'Love this pin! Where did you find it?',
        lastMessageTimeMs:
            now.subtract(const Duration(minutes: 5)).millisecondsSinceEpoch,
        isRead: false,
        unreadCount: 2,
      ),
      ConversationModel(
        id: 'conv_2',
        participantName: 'Alex Rivera',
        participantAvatar: 'https://i.pravatar.cc/150?img=3',
        lastMessage: 'Check out this board I made',
        lastMessageTimeMs:
            now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
        isRead: false,
        unreadCount: 1,
        isPinShare: true,
        sharedPinThumbnail:
            'https://images.pexels.com/photos/1029604/pexels-photo-1029604.jpeg?auto=compress&cs=tinysrgb&w=200',
      ),
      ConversationModel(
        id: 'conv_3',
        participantName: 'Maya Johnson',
        participantAvatar: 'https://i.pravatar.cc/150?img=5',
        lastMessage: 'Thanks for the inspiration! 🎨',
        lastMessageTimeMs:
            now.subtract(const Duration(hours: 3)).millisecondsSinceEpoch,
        isRead: true,
      ),
      ConversationModel(
        id: 'conv_4',
        participantName: 'James Wilson',
        participantAvatar: 'https://i.pravatar.cc/150?img=8',
        lastMessage: 'Would you like to collaborate on this board?',
        lastMessageTimeMs:
            now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        isRead: true,
      ),
      ConversationModel(
        id: 'conv_5',
        participantName: 'Emma Davis',
        participantAvatar: 'https://i.pravatar.cc/150?img=9',
        lastMessage: 'Shared a pin with you',
        lastMessageTimeMs:
            now.subtract(const Duration(days: 2)).millisecondsSinceEpoch,
        isRead: true,
        isPinShare: true,
        sharedPinThumbnail:
            'https://images.pexels.com/photos/1366919/pexels-photo-1366919.jpeg?auto=compress&cs=tinysrgb&w=200',
      ),
    ];
  }

  static List<InboxUpdateModel> generateUpdates() {
    final now = DateTime.now();
    return [
      InboxUpdateModel(
        id: 'update_1',
        title: 'Trending in your feed',
        body: 'Minimalist home decor is trending. Check out ideas!',
        avatarUrl: 'https://i.pravatar.cc/150?img=10',
        timestampMs:
            now.subtract(const Duration(minutes: 15)).millisecondsSinceEpoch,
        type: 'trending',
        isRead: false,
        thumbnailUrl:
            'https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg?auto=compress&cs=tinysrgb&w=200',
      ),
      InboxUpdateModel(
        id: 'update_2',
        title: 'Sarah Chen',
        body: 'Started following you',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        timestampMs:
            now.subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
        type: 'follow',
        isRead: false,
      ),
      InboxUpdateModel(
        id: 'update_3',
        title: 'Pin recommendation',
        body: 'Based on your taste: Modern Architecture',
        avatarUrl: 'https://i.pravatar.cc/150?img=12',
        timestampMs:
            now.subtract(const Duration(hours: 6)).millisecondsSinceEpoch,
        type: 'pinRecommendation',
        isRead: true,
        thumbnailUrl:
            'https://images.pexels.com/photos/323780/pexels-photo-323780.jpeg?auto=compress&cs=tinysrgb&w=200',
      ),
      InboxUpdateModel(
        id: 'update_4',
        title: 'Alex Rivera',
        body: 'Liked your pin "Sunset Vibes"',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        timestampMs:
            now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        type: 'like',
        isRead: true,
      ),
      InboxUpdateModel(
        id: 'update_5',
        title: 'Board invite',
        body: 'Maya invited you to "Travel Goals 2026"',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
        timestampMs:
            now.subtract(const Duration(days: 1, hours: 5)).millisecondsSinceEpoch,
        type: 'boardInvite',
        isRead: true,
        thumbnailUrl:
            'https://images.pexels.com/photos/2265876/pexels-photo-2265876.jpeg?auto=compress&cs=tinysrgb&w=200',
      ),
      InboxUpdateModel(
        id: 'update_6',
        title: 'James Wilson',
        body: 'Commented on your pin: "Amazing shot!"',
        avatarUrl: 'https://i.pravatar.cc/150?img=8',
        timestampMs:
            now.subtract(const Duration(days: 3)).millisecondsSinceEpoch,
        type: 'comment',
        isRead: true,
      ),
    ];
  }

  /// Generate mock messages for a conversation.
  static List<MessageModel> generateMessages(String conversationId) {
    final now = DateTime.now();

    switch (conversationId) {
      case 'conv_1':
        return [
          MessageModel(
            id: 'msg_1_1',
            conversationId: conversationId,
            senderId: 'me',
            senderName: 'You',
            senderAvatar: '',
            content: 'Hey! Check out this amazing design I found',
            timestampMs: now
                .subtract(const Duration(hours: 1))
                .millisecondsSinceEpoch,
            type: 'text',
            isMe: true,
          ),
          MessageModel(
            id: 'msg_1_2',
            conversationId: conversationId,
            senderId: 'sarah',
            senderName: 'Sarah Chen',
            senderAvatar: 'https://i.pravatar.cc/150?img=1',
            content: 'Oh wow, that looks incredible!',
            timestampMs: now
                .subtract(const Duration(minutes: 45))
                .millisecondsSinceEpoch,
            type: 'text',
          ),
          MessageModel(
            id: 'msg_1_3',
            conversationId: conversationId,
            senderId: 'me',
            senderName: 'You',
            senderAvatar: '',
            content: 'Right? I was thinking of trying something similar',
            timestampMs: now
                .subtract(const Duration(minutes: 30))
                .millisecondsSinceEpoch,
            type: 'text',
            isMe: true,
          ),
          MessageModel(
            id: 'msg_1_4',
            conversationId: conversationId,
            senderId: 'sarah',
            senderName: 'Sarah Chen',
            senderAvatar: 'https://i.pravatar.cc/150?img=1',
            content: 'You should! Would love to see your take on it',
            timestampMs: now
                .subtract(const Duration(minutes: 10))
                .millisecondsSinceEpoch,
            type: 'text',
          ),
          MessageModel(
            id: 'msg_1_5',
            conversationId: conversationId,
            senderId: 'sarah',
            senderName: 'Sarah Chen',
            senderAvatar: 'https://i.pravatar.cc/150?img=1',
            content: 'Love this pin! Where did you find it?',
            timestampMs: now
                .subtract(const Duration(minutes: 5))
                .millisecondsSinceEpoch,
            type: 'text',
          ),
        ];

      case 'conv_2':
        return [
          MessageModel(
            id: 'msg_2_1',
            conversationId: conversationId,
            senderId: 'alex',
            senderName: 'Alex Rivera',
            senderAvatar: 'https://i.pravatar.cc/150?img=3',
            content: 'I created a new board for our trip!',
            timestampMs: now
                .subtract(const Duration(hours: 2))
                .millisecondsSinceEpoch,
            type: 'text',
          ),
          MessageModel(
            id: 'msg_2_2',
            conversationId: conversationId,
            senderId: 'alex',
            senderName: 'Alex Rivera',
            senderAvatar: 'https://i.pravatar.cc/150?img=3',
            content: 'Check out this board I made',
            timestampMs: now
                .subtract(const Duration(hours: 1))
                .millisecondsSinceEpoch,
            type: 'pinShare',
            pinThumbnail:
                'https://images.pexels.com/photos/1029604/pexels-photo-1029604.jpeg?auto=compress&cs=tinysrgb&w=200',
          ),
        ];

      default:
        return [
          MessageModel(
            id: 'msg_default_1',
            conversationId: conversationId,
            senderId: 'other',
            senderName: 'User',
            senderAvatar: 'https://i.pravatar.cc/150?img=10',
            content: 'Hey there! 👋',
            timestampMs: now
                .subtract(const Duration(days: 1))
                .millisecondsSinceEpoch,
            type: 'text',
          ),
        ];
    }
  }
}
