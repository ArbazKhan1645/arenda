import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _HeaderSection(),
            Expanded(
              child: switch (state) {
                ChatLoading() => const _LoadingView(),
                ChatLoaded(:final conversations) =>
                  conversations.isEmpty
                      ? const _EmptyInbox()
                      : _ConversationList(conversations: conversations),
                ChatError(:final message) => Center(child: Text(message)),
              },
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// HEADER (Title + Search + Filters)
////////////////////////////////////////////////////////////

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Messages", style: AppTextStyles.h2),
              Icon(PhosphorIcons.dotsThreeVertical()),
            ],
          ),

          const SizedBox(height: 16),

          /// Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Search conversations...",
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 14),

          /// Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                _FilterChip(label: "All", selected: true),
                _FilterChip(label: "Unread"),
                _FilterChip(label: "Active"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// FILTER CHIP
////////////////////////////////////////////////////////////

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _FilterChip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySM.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// LOADING
////////////////////////////////////////////////////////////

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingPage,
      ),
      itemCount: 5,
      itemBuilder: (_, __) => const ChatTileShimmer(),
    );
  }
}

////////////////////////////////////////////////////////////
/// LIST
////////////////////////////////////////////////////////////

class _ConversationList extends StatelessWidget {
  const _ConversationList({required this.conversations});
  final List<ConversationEntity> conversations;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingPage,
      ),
      itemCount: conversations.length,
      itemBuilder: (_, i) =>
          _ConversationCard(conversation: conversations[i], index: i),
    );
  }
}

////////////////////////////////////////////////////////////
/// MODERN CARD TILE
////////////////////////////////////////////////////////////

class _ConversationCard extends StatelessWidget {
  final ConversationEntity conversation;
  final int index;

  const _ConversationCard({required this.conversation, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () =>
                context.push(AppRoutes.conversationPath(conversation.id)),
            child: Row(
              children: [
                /// Avatar
                Stack(
                  children: [
                    AppAvatar(
                      imageUrl: conversation.otherUserAvatarUrl,
                      name: conversation.otherUserName,
                      size: AppDimensions.avatarMD,
                    ),
                    if (conversation.unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${conversation.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 12),

                /// Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Name + Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            conversation.otherUserName,
                            style: AppTextStyles.labelMD,
                          ),
                          Text(
                            conversation.formattedTime,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      /// Listing
                      if (conversation.listingTitle != null)
                        Text(
                          conversation.listingTitle!,
                          style: AppTextStyles.bodyXS.copyWith(
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const SizedBox(height: 4),

                      /// Message
                      Text(
                        conversation.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMD.copyWith(
                          fontWeight: conversation.unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: conversation.unreadCount > 0
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 50 * index))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1);
  }
}

////////////////////////////////////////////////////////////
/// EMPTY STATE
////////////////////////////////////////////////////////////

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIcons.chatCircle(), size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          Text('No messages yet', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            'Your conversations will appear here',
            style: AppTextStyles.bodyMD.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
