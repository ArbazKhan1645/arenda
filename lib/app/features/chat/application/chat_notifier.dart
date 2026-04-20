import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:arenda/app/features/chat/data/datasources/mock_chat_datasource.dart';
import 'package:arenda/app/features/chat/domain/entities/conversation_entity.dart';

part 'chat_notifier.g.dart';

// ── Chat list ──────────────────────────────────────────────────────────────

sealed class ChatState {
  const ChatState();
}

final class ChatLoading extends ChatState {
  const ChatLoading();
}

final class ChatLoaded extends ChatState {
  const ChatLoaded(this.conversations);
  final List<ConversationEntity> conversations;
}

final class ChatError extends ChatState {
  const ChatError(this.message);
  final String message;
}

@Riverpod(keepAlive: true)
class ChatNotifier extends _$ChatNotifier {
  @override
  ChatState build() {
    _load();
    return const ChatLoading();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 500));
    state = ChatLoaded(MockChatDataSource.getConversations());
  }
}

// ── Conversation ───────────────────────────────────────────────────────────

sealed class ConversationState {
  const ConversationState();
}

final class ConversationLoading extends ConversationState {
  const ConversationLoading();
}

final class ConversationLoaded extends ConversationState {
  const ConversationLoaded({
    required this.conversation,
    required this.messages,
  });
  final ConversationEntity conversation;
  final List<MessageEntity> messages;
}

@Riverpod()
class ConversationNotifier extends _$ConversationNotifier {
  @override
  ConversationState build() => const ConversationLoading();

  Future<void> load(String conversationId) async {
    state = const ConversationLoading();
    await Future.delayed(const Duration(milliseconds: 300));
    final conversations = MockChatDataSource.getConversations();
    final conversation = conversations.firstWhere(
      (c) => c.id == conversationId,
    );
    final messages = MockChatDataSource.getMessages(conversationId);
    state = ConversationLoaded(conversation: conversation, messages: messages);
  }

  void sendMessage(String content) {
    final current = state;
    if (current is! ConversationLoaded) return;
    final newMsg = MessageEntity(
      id: 'm${DateTime.now().millisecondsSinceEpoch}',
      conversationId: current.conversation.id,
      senderId: 'u1',
      content: content,
      sentAt: DateTime.now(),
    );
    state = ConversationLoaded(
      conversation: current.conversation,
      messages: [...current.messages, newMsg],
    );
  }
}
