import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:arenda/app/core/routes/app_routes.dart';
import 'package:arenda/app/core/theme/app_colors.dart';
import 'package:arenda/app/core/theme/app_dimensions.dart';
import 'package:arenda/app/core/theme/app_text_styles.dart';
import 'package:arenda/app/shared/widgets/app_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TrustSafetyScreen extends StatelessWidget {
  const TrustSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trust & Safety'),
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft()),
          onPressed: () => context.pop(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Hero ──────────────────────────────────────────────────
          SliverToBoxAdapter(child: _Hero().animate().fadeIn(duration: 500.ms)),

          SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.paddingPage),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Escrow Section ───────────────────────────────────
                _SectionHeader(
                  icon: PhosphorIcons.lock(),
                  title: 'Escrow-Protected Payments',
                  color: AppColors.primary,
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceLG),
                _EscrowTimeline()
                    .animate(delay: 150.ms)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.space3XL),
                const Divider(),
                const SizedBox(height: AppDimensions.space3XL),

                // ── ID Verification Section ──────────────────────────
                _SectionHeader(
                  icon: PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
                  title: 'Guest ID Verification',
                  color: AppColors.primaryDark,
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceLG),
                ..._idPoints.asMap().entries.map(
                  (e) => _BulletPoint(text: e.value, delay: 230 + e.key * 50),
                ),

                const SizedBox(height: AppDimensions.space2XL),
                AppButton(
                  label: 'Verify my ID now',
                  variant: AppButtonVariant.outline,
                  prefixIcon: Icon(
                    PhosphorIcons.identificationCard(),
                    size: 18,
                  ),
                  onPressed: () => context.push(AppRoutes.idVerification),
                ).animate(delay: 380.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.space3XL),
                const Divider(),
                const SizedBox(height: AppDimensions.space3XL),

                // ── Physical Vetting Section ─────────────────────────
                _SectionHeader(
                  icon: PhosphorIcons.house(),
                  title: 'Physical Property Vetting',
                  color: AppColors.success,
                ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceLG),
                _VettingCard().animate(delay: 440.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.space2XL),
                ..._vettingPoints.asMap().entries.map(
                  (e) => _BulletPoint(
                    text: e.value,
                    delay: 470 + e.key * 50,
                    color: AppColors.success,
                  ),
                ),

                const SizedBox(height: AppDimensions.space3XL),
                const Divider(),
                const SizedBox(height: AppDimensions.space3XL),

                // ── Payment Methods Section ──────────────────────────
                _SectionHeader(
                  icon: PhosphorIcons.deviceMobile(),
                  title: 'Mobile Money & Bank Payments',
                  color: const Color(0xFFFFC107),
                ).animate(delay: 580.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceLG),
                _PaymentMethodsGrid()
                    .animate(delay: 620.ms)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.space3XL),
                const Divider(),
                const SizedBox(height: AppDimensions.space3XL),

                // ── Guest Protection ─────────────────────────────────
                _SectionHeader(
                  icon: PhosphorIcons.shield(),
                  title: 'Guest Protection',
                  color: AppColors.error,
                ).animate(delay: 680.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceLG),
                ..._protectionPoints.asMap().entries.map(
                  (e) => _BulletPoint(
                    text: e.value,
                    delay: 710 + e.key * 50,
                    color: AppColors.error,
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  static const _idPoints = [
    'All guests must verify a government-issued photo ID before their first booking.',
    'Accepted IDs: Ghana Card, NIN, Voter\'s ID, International Passport, Driver\'s License.',
    'Your ID is encrypted with AES-256 and only shared with hosts after a confirmed booking.',
    'Face-match technology ensures the person checking in matches the verified ID.',
  ];

  static const _vettingPoints = [
    'Our local team physically visits and photographs every listed property.',
    'We verify power backup (solar/generator), internet speed, and water supply claims.',
    'We confirm the host\'s identity and ownership of the property.',
    'Properties failing our standards are delisted within 24 hours.',
  ];

  static const _protectionPoints = [
    'Full refund if the property doesn\'t match its listing description.',
    'Emergency re-accommodation support within 2 hours.',
    '24/7 guest support line with local language agents.',
    'Dispute resolution within 48 hours — funds held until resolved.',
  ];
}

// ── Hero ───────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space3XL),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
        ),
      ),
      child: Column(
        children: [
          Icon(PhosphorIcons.shieldCheck(), size: 56, color: Colors.white),
          const SizedBox(height: AppDimensions.spaceLG),
          Text(
            'Built for West Africa',
            style: AppTextStyles.h2.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            'Every feature is designed around the trust, payment, and navigation realities of our region.',
            style: AppTextStyles.bodyMD.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: AppDimensions.spaceLG),
        Expanded(child: Text(title, style: AppTextStyles.h3)),
      ],
    );
  }
}

// ── Escrow Timeline ────────────────────────────────────────────────────────

class _EscrowTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        icon: '💳',
        title: 'Guest pays',
        desc:
            'You pay via MoMo or Bank Transfer. Funds go into secure escrow — not to the host yet.',
      ),
      (
        icon: '🔒',
        title: 'Funds held safely',
        desc:
            'Money is held by our payment partner (Flutterwave / Paystack) until you check in.',
      ),
      (
        icon: '🏠',
        title: 'You check in',
        desc:
            'Arrive at the property. If everything matches the listing, your stay continues.',
      ),
      (
        icon: '✅',
        title: 'Host receives payment',
        desc:
            '24–48 hours after check-in, funds are released to the host automatically.',
      ),
    ];

    return Column(
      children: steps.asMap().entries.map((e) {
        final isLast = e.key == steps.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Center(
                    child: Text(
                      e.value.icon,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 48,
                    color: AppColors.primary.withAlpha(60),
                  ),
              ],
            ),
            const SizedBox(width: AppDimensions.spaceLG),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.value.title, style: AppTextStyles.labelMD),
                    const SizedBox(height: 4),
                    Text(
                      e.value.desc,
                      style: AppTextStyles.bodyMD.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// ── Vetting Card ───────────────────────────────────────────────────────────

class _VettingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.success.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Text('🏡', style: TextStyle(fontSize: 40)),
          const SizedBox(width: AppDimensions.spaceLG),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Physically Vetted',
                  style: AppTextStyles.labelMD.copyWith(
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Look for this badge on listings. It means our team has personally visited and verified the property.',
                  style: AppTextStyles.bodyXS.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payment Methods Grid ───────────────────────────────────────────────────

class _PaymentMethodsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const methods = [
      ('📱', 'MTN MoMo'),
      ('🟠', 'Orange Money'),
      ('🌊', 'Wave'),
      ('🏦', 'Bank Transfer'),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppDimensions.spaceMD,
      mainAxisSpacing: AppDimensions.spaceMD,
      childAspectRatio: 2.8,
      children: methods
          .map(
            (m) => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(m.$1, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(m.$2, style: AppTextStyles.labelSM),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

// ── Bullet Point ───────────────────────────────────────────────────────────

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({
    required this.text,
    required this.delay,
    this.color = AppColors.primary,
  });

  final String text;
  final int delay;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spaceMD),
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.bodyMD.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.04, end: 0, duration: 350.ms);
  }
}
