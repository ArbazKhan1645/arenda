import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:arenda/app/core/routes/app_routes.dart';
import 'package:arenda/app/core/theme/app_colors.dart';
import 'package:arenda/app/core/theme/app_dimensions.dart';
import 'package:arenda/app/core/theme/app_text_styles.dart';
import 'package:arenda/app/shared/widgets/app_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BecomeHostScreen extends StatefulWidget {
  const BecomeHostScreen({super.key});

  @override
  State<BecomeHostScreen> createState() => _BecomeHostScreenState();
}

class _BecomeHostScreenState extends State<BecomeHostScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _HostPage(
      emoji: '🏠',
      title: 'Share your space,\nearn in local currency',
      body:
          'Whether you have a spare room, a shortlet, or a full villa — list it on Arenda and start earning. Hosts in Accra and Lagos are making ₵3,000–₵18,000 per month.',
      highlight: '₵3,000–₵18,000/month',
      highlightLabel: 'Average host earnings',
    ),
    _HostPage(
      emoji: '💳',
      title: 'Get paid the way\nyou prefer',
      body:
          'Choose your payout method: MTN MoMo, Orange Money, Wave, or direct bank transfer. Payments are released automatically 24–48 hours after guest check-in.',
      highlight: '24–48 hrs',
      highlightLabel: 'Payout after check-in',
    ),
    _HostPage(
      emoji: '🔒',
      title: 'We protect you\nand your property',
      body:
          'All guests are ID-verified before they book. Our escrow system holds payment securely — you only receive funds once the guest has checked in successfully.',
      highlight: '100% ID verified',
      highlightLabel: 'Every guest, every booking',
    ),
    _HostPage(
      emoji: '✅',
      title: 'Listing takes\njust 10 minutes',
      body:
          'Answer a few questions about your space, set your price in your local currency, describe your landmark, and add photos. Our team visits to physically vet your property.',
      highlight: '10 mins',
      highlightLabel: 'To create your first listing',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(PhosphorIcons.x()),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!isLast)
            TextButton(
              onPressed: () =>
                  context.pushReplacement(AppRoutes.hostCreateListing),
              child: Text(
                'Skip',
                style: AppTextStyles.labelMD.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => _PageContent(page: _pages[i]),
            ),
          ),

          // ── Bottom controls ────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.paddingPage,
              AppDimensions.spaceLG,
              AppDimensions.paddingPage,
              MediaQuery.of(context).padding.bottom + AppDimensions.spaceLG,
            ),
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: _pages.length,
                  effect: const WormEffect(
                    dotWidth: 8,
                    dotHeight: 8,
                    activeDotColor: AppColors.primary,
                    dotColor: AppColors.border,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceLG),
                AppButton(
                  label: isLast ? 'List your property' : 'Next',
                  onPressed: () {
                    if (isLast) {
                      context.pushReplacement(AppRoutes.hostCreateListing);
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HostPage {
  const _HostPage({
    required this.emoji,
    required this.title,
    required this.body,
    required this.highlight,
    required this.highlightLabel,
  });

  final String emoji;
  final String title;
  final String body;
  final String highlight;
  final String highlightLabel;
}

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page});

  final _HostPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji
          Text(
            page.emoji,
            style: const TextStyle(fontSize: 40),
          ).animate().scale(
            begin: const Offset(0.7, 0.7),
            duration: 500.ms,
            curve: Curves.elasticOut,
          ),

          const SizedBox(height: AppDimensions.spaceMD),

          // Title
          Text(
            page.title,
            style: AppTextStyles.h1.copyWith(height: 1.25),
            textAlign: TextAlign.center,
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: AppDimensions.spaceXXL),

          // Highlight card
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space2XL,
                  vertical: AppDimensions.spaceLG,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                ),
                child: Column(
                  children: [
                    Text(
                      page.highlight,
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.primaryDark,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      page.highlightLabel,
                      style: AppTextStyles.bodySM.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              )
              .animate(delay: 200.ms)
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.95, 0.95), duration: 400.ms),

          const SizedBox(height: AppDimensions.space2XL),

          // Body
          Text(
            page.body,
            style: AppTextStyles.bodySM.copyWith(
              color: AppColors.textSecondary,
              height: 1.65,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 280.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}
