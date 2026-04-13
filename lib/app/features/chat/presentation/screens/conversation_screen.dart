import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../application/chat_notifier.dart';
import '../../domain/entities/conversation_entity.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key, required this.conversationId});
  final String conversationId;

  @override
  ConsumerState<ConversationScreen> createState() =>
      _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(conversationProvider.notifier)
          .load(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    ref.read(conversationProvider.notifier).sendMessage(text);
    _msgCtrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationProvider);

    return Scaffold(
      appBar: state is ConversationLoaded
          ? _ConversationAppBar(conversation: state.conversation)
          : AppBar(),
      body: switch (state) {
        ConversationLoading() =>
          const Center(child: CircularProgressIndicator()),
        ConversationLoaded(:final messages) => Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(AppDimensions.paddingPage),
                  itemCount: messages.length,
                  itemBuilder: (_, i) => _MessageBubble(
                    message: messages[i],
                    isMe: messages[i].senderId == 'u1',
                    index: i,
                  ),
                ),
              ),
              _MessageInput(
                controller: _msgCtrl,
                onSend: _send,
              ),
            ],
          ),
      },
    );
  }
}

class _ConversationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _ConversationAppBar({required this.conversation});
  final ConversationEntity conversation;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          AppAvatar(
            imageUrl: conversation.otherUserAvatarUrl,
            name: conversation.otherUserName,
            size: 36,
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(conversation.otherUserName,
                  style: AppTextStyles.labelMD),
              if (conversation.listingTitle != null)
                Text(conversation.listingTitle!,
                    style: AppTextStyles.bodyXS.copyWith(
                        color: AppColors.primary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.index,
  });

  final MessageEntity message;
  final bool isMe;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceSM),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            const SizedBox(width: 4),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceLG,
                vertical: AppDimensions.spaceMD,
              ),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppDimensions.radiusLG),
                  topRight: const Radius.circular(AppDimensions.radiusLG),
                  bottomLeft: Radius.circular(isMe ? AppDimensions.radiusLG : 4),
                  bottomRight: Radius.circular(isMe ? 4 : AppDimensions.radiusLG),
                ),
                border: isMe
                    ? null
                    : Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.content,
                    style: AppTextStyles.bodyMD.copyWith(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message.formattedTime,
                    style: AppTextStyles.caption.copyWith(
                      color: isMe
                          ? Colors.white70
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 30 * index)).fadeIn(duration: 300.ms);
  }
}

class _MessageInput extends StatelessWidget {
  const _MessageInput({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.paddingPage,
        AppDimensions.spaceSM,
        AppDimensions.paddingPage,
        MediaQuery.of(context).padding.bottom + AppDimensions.spaceSM,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusFull),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: controller,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Message...',
                  hintStyle: AppTextStyles.bodyMD
                      .copyWith(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceLG,
                    vertical: AppDimensions.spaceMD,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceSM),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
