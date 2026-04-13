import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../application/chat_notifier.dart';
import '../../domain/entities/conversation_entity.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: switch (state) {
        ChatLoading() => _LoadingView(),
        ChatLoaded(:final conversations) => conversations.isEmpty
            ? _EmptyInbox()
            : _ConversationList(conversations: conversations),
        ChatError(:final message) => Center(child: Text(message)),
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) => const ChatTileShimmer(),
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({required this.conversations});
  final List<ConversationEntity> conversations;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: conversations.length,
      separatorBuilder: (_, __) => const Divider(indent: 76),
      itemBuilder: (_, i) => _ConversationTile(
        conversation: conversations[i],
        index: i,
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.index});
  final ConversationEntity conversation;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingPage,
        vertical: AppDimensions.spaceXS,
      ),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          AppAvatar(
            imageUrl: conversation.otherUserAvatarUrl,
            name: conversation.otherUserName,
            size: AppDimensions.avatarMD,
          ),
          if (conversation.unreadCount > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${conversation.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.otherUserName,
              style: AppTextStyles.labelMD,
            ),
          ),
          Text(
            conversation.formattedTime,
            style: AppTextStyles.caption,
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (conversation.listingTitle != null)
            Text(
              conversation.listingTitle!,
              style: AppTextStyles.bodyXS.copyWith(
                color: AppColors.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Text(
            conversation.lastMessage,
            style: AppTextStyles.bodyMD.copyWith(
              color: conversation.unreadCount > 0
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: conversation.unreadCount > 0
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      onTap: () => context.push(AppRoutes.conversationPath(conversation.id)),
    )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: 400.ms);
  }
}

class _EmptyInbox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chat_bubble_outline_rounded,
              size: 64, color: AppColors.border),
          const SizedBox(height: AppDimensions.spaceLG),
          Text('No messages yet', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            'When you contact a host, your messages will appear here',
            style:
                AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
