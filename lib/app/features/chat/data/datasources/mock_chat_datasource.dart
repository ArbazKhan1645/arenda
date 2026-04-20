import 'package:arenda/app/features/chat/domain/entities/conversation_entity.dart';

abstract final class MockChatDataSource {
  static List<ConversationEntity> getConversations() => _conversations;

  static List<MessageEntity> getMessages(String conversationId) =>
      _messages[conversationId] ?? [];

  static final List<ConversationEntity> _conversations = [
    ConversationEntity(
      id: 'c1',
      otherUserId: 'h1',
      otherUserName: 'Sarah Chen',
      otherUserAvatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
      lastMessage: 'The villa is available for those dates! Shall I confirm?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
      unreadCount: 2,
      listingTitle: 'Stunning Beachfront Villa with Private Pool',
      listingThumbnail:
          'https://images.unsplash.com/photo-1582268611958-ebfd161ef9cf?auto=format&fit=crop&w=400&q=80',
    ),
    ConversationEntity(
      id: 'c2',
      otherUserId: 'h2',
      otherUserName: 'Marcus Weber',
      otherUserAvatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      lastMessage: 'Great! I\'ll leave the key in the lockbox.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      listingTitle: 'Cozy Alpine Cabin with Mountain Views',
      listingThumbnail:
          'https://images.unsplash.com/photo-1449844908441-8195982a4be4?auto=format&fit=crop&w=400&q=80',
    ),
    ConversationEntity(
      id: 'c3',
      otherUserId: 'h5',
      otherUserName: 'Aisha Mohamed',
      otherUserAvatarUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
      lastMessage: 'Your transfer has been arranged for 2 PM.',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 1,
      listingTitle: 'Luxury Overwater Bungalow in the Maldives',
      listingThumbnail:
          'https://images.unsplash.com/photo-1573843981267-be1999ff37cd?auto=format&fit=crop&w=400&q=80',
    ),
    ConversationEntity(
      id: 'c4',
      otherUserId: 'h7',
      otherUserName: 'Ryan Blake',
      otherUserAvatarUrl:
          'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=200&q=80',
      lastMessage:
          'Enjoy the stars tonight! The telescope is set up on the deck.',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
      listingTitle: 'Minimalist Desert Retreat',
      listingThumbnail:
          'https://images.unsplash.com/photo-1512917774899-1a3a02bab173?auto=format&fit=crop&w=400&q=80',
    ),
  ];

  static final Map<String, List<MessageEntity>> _messages = {
    'c1': [
      MessageEntity(
        id: 'm1',
        conversationId: 'c1',
        senderId: 'u1',
        content:
            'Hi Sarah! I\'m interested in booking your villa from Dec 20-27. Is it available?',
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      MessageEntity(
        id: 'm2',
        conversationId: 'c1',
        senderId: 'h1',
        content:
            'Hello! Yes, those dates look perfect. We\'d love to host you and your group!',
        sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        isRead: true,
      ),
      MessageEntity(
        id: 'm3',
        conversationId: 'c1',
        senderId: 'u1',
        content:
            'Wonderful! We\'ll be 6 adults. Are there any special check-in instructions?',
        sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        isRead: true,
      ),
      MessageEntity(
        id: 'm4',
        conversationId: 'c1',
        senderId: 'h1',
        content:
            'Perfect! Check-in is from 3 PM. I\'ll send you the gate code and villa orientation guide closer to your arrival.',
        sentAt: DateTime.now().subtract(const Duration(minutes: 45)),
        isRead: true,
      ),
      MessageEntity(
        id: 'm5',
        conversationId: 'c1',
        senderId: 'h1',
        content: 'The villa is available for those dates! Shall I confirm?',
        sentAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ],
    'c2': [
      MessageEntity(
        id: 'm6',
        conversationId: 'c2',
        senderId: 'u1',
        content: 'Hi Marcus, what time is earliest check-in?',
        sentAt: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: true,
      ),
      MessageEntity(
        id: 'm7',
        conversationId: 'c2',
        senderId: 'h2',
        content:
            'Check-in starts at 2 PM, but I can sometimes arrange early check-in. Let me know your arrival time!',
        sentAt: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: true,
      ),
      MessageEntity(
        id: 'm8',
        conversationId: 'c2',
        senderId: 'u1',
        content: 'We\'ll arrive around 1 PM. Would that work?',
        sentAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 30)),
        isRead: true,
      ),
      MessageEntity(
        id: 'm9',
        conversationId: 'c2',
        senderId: 'h2',
        content: 'Great! I\'ll leave the key in the lockbox.',
        sentAt: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: true,
      ),
    ],
  };
}
