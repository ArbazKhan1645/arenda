class ConversationEntity {
  const ConversationEntity({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.listingTitle,
    this.listingThumbnail,
  });

  final String id;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String? listingTitle;
  final String? listingThumbnail;

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(lastMessageTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${lastMessageTime.day}/${lastMessageTime.month}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ConversationEntity && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

class MessageEntity {
  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.sentAt,
    this.isRead = false,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime sentAt;
  final bool isRead;

  String get formattedTime {
    final h = sentAt.hour;
    final m = sentAt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:$m $period';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MessageEntity && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
