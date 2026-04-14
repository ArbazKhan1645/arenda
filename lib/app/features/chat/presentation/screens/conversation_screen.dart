import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationProvider.notifier).load(widget.conversationId);
    });
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    ref.read(conversationProvider.notifier).sendMessage(text);
    _msgCtrl.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
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
      backgroundColor: AppColors.background,

      /// APP BAR
      appBar: state is ConversationLoaded
          ? _ModernAppBar(conversation: state.conversation)
          : AppBar(),

      body: switch (state) {
        ConversationLoading() => const Center(
          child: CircularProgressIndicator(),
        ),

        ConversationLoaded(:final messages) => Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingPage,
                  vertical: 12,
                ),
                itemCount: messages.length,
                itemBuilder: (_, i) => _MessageBubble(
                  message: messages[i],
                  isMe: messages[i].senderId == 'u1',
                  index: i,
                ),
              ),
            ),

            /// INPUT
            _ModernInput(controller: _msgCtrl, onSend: _send),
          ],
        ),
      },
    );
  }
}

////////////////////////////////////////////////////////////
/// 🔥 MODERN APPBAR
////////////////////////////////////////////////////////////

class _ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ConversationEntity conversation;

  const _ModernAppBar({required this.conversation});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.5,
      titleSpacing: 0,
      title: Row(
        children: [
          AppAvatar(
            imageUrl: conversation.otherUserAvatarUrl,
            name: conversation.otherUserName,
            size: 40,
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(conversation.otherUserName, style: AppTextStyles.labelMD),

              const SizedBox(height: 2),

              Text(
                "Online",
                style: AppTextStyles.caption.copyWith(color: Colors.green),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: Icon(PhosphorIcons.phone()), onPressed: () {}),
        IconButton(icon: Icon(PhosphorIcons.videoCamera()), onPressed: () {}),
      ],
    );
  }
}

////////////////////////////////////////////////////////////
/// 💬 MODERN BUBBLE
////////////////////////////////////////////////////////////

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final int index;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (!isMe)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                        ),
                    ],
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
                      const SizedBox(height: 4),
                      Text(
                        message.formattedTime,
                        style: AppTextStyles.caption.copyWith(
                          color: isMe ? Colors.white70 : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 25 * index))
        .fadeIn(duration: 250.ms)
        .slideY(begin: 0.1);
  }
}

////////////////////////////////////////////////////////////
/// ✍️ MODERN INPUT
////////////////////////////////////////////////////////////

class _ModernInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ModernInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        10,
        12,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: controller,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.paperPlaneTilt(PhosphorIconsStyle.fill),
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
