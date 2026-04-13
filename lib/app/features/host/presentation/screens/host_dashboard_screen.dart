import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../home/domain/entities/listing_entity.dart';
import '../../application/host_notifier.dart';

class HostDashboardScreen extends ConsumerStatefulWidget {
  const HostDashboardScreen({super.key});

  @override
  ConsumerState<HostDashboardScreen> createState() =>
      _HostDashboardScreenState();
}

class _HostDashboardScreenState extends ConsumerState<HostDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(hostProvider.notifier).load('h1'));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hostProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Host Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: switch (state) {
        HostLoading() => _LoadingView(),
        final HostLoaded loaded => _LoadedView(state: loaded),
        HostError(:final message) => Center(child: Text(message)),
      },
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add listing'),
        onPressed: () => context.push(AppRoutes.hostCreateListing),
      ),
    );
  }
}

// ── Loading ────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      child: Column(
        children: [
          AppShimmer(width: double.infinity, height: 140, borderRadius: 16),
          const SizedBox(height: AppDimensions.spaceXXL),
          AppShimmer(width: double.infinity, height: 20, borderRadius: 4),
          const SizedBox(height: AppDimensions.spaceMD),
          AppShimmer(width: 200, height: 16, borderRadius: 4),
          const SizedBox(height: AppDimensions.spaceXXL),
          AppShimmer(width: double.infinity, height: 120, borderRadius: 12),
          const SizedBox(height: AppDimensions.spaceLG),
          AppShimmer(width: double.infinity, height: 120, borderRadius: 12),
        ],
      ),
    );
  }
}

// ── Loaded ─────────────────────────────────────────────────────────────────

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.state});

  final HostLoaded state;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {},
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.paddingPage),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Earnings Card ──────────────────────────────────
                _EarningsCard(state: state)
                    .animate()
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceXXL),

                // ── Stats Row ──────────────────────────────────────
                _StatsRow(state: state)
                    .animate(delay: 80.ms)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceXXL),
                const Divider(),
                const SizedBox(height: AppDimensions.spaceXXL),

                // ── Quick Actions ──────────────────────────────────
                Text('Quick actions', style: AppTextStyles.h3)
                    .animate(delay: 120.ms)
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: AppDimensions.spaceLG),
                _QuickActions()
                    .animate(delay: 150.ms)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceXXL),
                const Divider(),
                const SizedBox(height: AppDimensions.spaceXXL),

                // ── Verification Status ────────────────────────────
                _VerificationStatus(isVerified: state.isIdVerified)
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceXXL),
                const Divider(),
                const SizedBox(height: AppDimensions.spaceXXL),

                // ── My Listings ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('My listings', style: AppTextStyles.h3),
                    TextButton(
                      onPressed: () =>
                          context.push(AppRoutes.hostCreateListing),
                      child: Text(
                        '+ Add new',
                        style: AppTextStyles.labelSM
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ).animate(delay: 250.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceLG),

                if (state.myListings.isEmpty)
                  _EmptyListings()
                else
                  ...state.myListings.asMap().entries.map(
                    (e) => _HostListingTile(
                      listing: e.value,
                      index: e.key,
                    ),
                  ),

                // Bottom padding for FAB
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Earnings Card ──────────────────────────────────────────────────────────

class _EarningsCard extends StatelessWidget {
  const _EarningsCard({required this.state});

  final HostLoaded state;

  @override
  Widget build(BuildContext context) {
    final sym = state.localCurrency == 'NGN' ? '₦' :
                state.localCurrency == 'XOF' ? 'CFA ' : '₵';
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Earnings this month',
                style: AppTextStyles.bodyMD.copyWith(color: Colors.white70),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  state.localCurrency,
                  style: AppTextStyles.labelSM.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            '$sym${state.earningsThisMonth.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXXL),
          Row(
            children: [
              _EarningsStat(
                label: 'Total earned',
                value: '$sym${state.totalEarnings.toStringAsFixed(0)}',
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white38,
                margin: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceLG),
              ),
              _EarningsStat(
                label: 'Active listings',
                value: '${state.myListings.length}',
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white38,
                margin: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceLG),
              ),
              _EarningsStat(
                label: 'Payout via',
                value: state.preferredPayoutMethod ?? 'Not set',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EarningsStat extends StatelessWidget {
  const _EarningsStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: AppTextStyles.labelMD.copyWith(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(label,
              style: AppTextStyles.bodyXS.copyWith(color: Colors.white60),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ── Stats Row ──────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.state});

  final HostLoaded state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          label: 'Pending',
          value: '${state.pendingBookingsCount}',
          icon: Icons.pending_actions_rounded,
          color: AppColors.warning,
        ),
        const SizedBox(width: AppDimensions.spaceMD),
        _StatCard(
          label: 'Completed',
          value: '${state.completedBookingsCount}',
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.success,
        ),
        const SizedBox(width: AppDimensions.spaceMD),
        _StatCard(
          label: 'Avg rating',
          value: '4.9 ⭐',
          icon: Icons.star_outline_rounded,
          color: AppColors.star,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceMD),
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppDimensions.spaceXS),
            Text(value,
                style: AppTextStyles.labelLG.copyWith(color: color)),
            Text(label,
                style: AppTextStyles.bodyXS
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ── Quick Actions ──────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (icon: Icons.add_home_rounded,     label: 'Add listing',    route: AppRoutes.hostCreateListing),
      (icon: Icons.account_balance_wallet_rounded, label: 'Payouts', route: AppRoutes.payoutPreferences),
      (icon: Icons.security_rounded,     label: 'Trust & Safety', route: AppRoutes.trustSafety),
      (icon: Icons.badge_rounded,        label: 'Verify ID',      route: AppRoutes.idVerification),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppDimensions.spaceSM,
      children: actions
          .map(
            (a) => GestureDetector(
              onTap: () => context.push(a.route),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMD),
                    ),
                    child: Icon(a.icon,
                        color: AppColors.primaryDark, size: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    a.label,
                    style: AppTextStyles.bodyXS,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

// ── Verification Status ────────────────────────────────────────────────────

class _VerificationStatus extends StatelessWidget {
  const _VerificationStatus({required this.isVerified});

  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        color: isVerified
            ? AppColors.success.withAlpha(15)
            : AppColors.warning.withAlpha(15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(
          color: isVerified
              ? AppColors.success.withAlpha(80)
              : AppColors.warning.withAlpha(80),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isVerified
                ? Icons.verified_user_rounded
                : Icons.warning_amber_rounded,
            color: isVerified ? AppColors.success : AppColors.warning,
            size: 28,
          ),
          const SizedBox(width: AppDimensions.spaceLG),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVerified ? 'ID Verified ✓' : 'ID Verification Pending',
                  style: AppTextStyles.labelMD.copyWith(
                    color: isVerified ? AppColors.success : AppColors.warning,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isVerified
                      ? 'Your identity has been verified. Guests can book with confidence.'
                      : 'Verify your ID to increase trust and booking rates.',
                  style: AppTextStyles.bodyXS
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (!isVerified)
            TextButton(
              onPressed: () => context.push(AppRoutes.idVerification),
              child: const Text('Verify'),
            ),
        ],
      ),
    );
  }
}

// ── Host Listing Tile ──────────────────────────────────────────────────────

class _HostListingTile extends StatelessWidget {
  const _HostListingTile({required this.listing, required this.index});

  final ListingEntity listing;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceLG),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.radiusLG),
              bottomLeft: Radius.circular(AppDimensions.radiusLG),
            ),
            child: AppImage(
              url: listing.thumbnailUrl,
              width: 100,
              height: 100,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: AppTextStyles.labelMD,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    listing.city,
                    style: AppTextStyles.bodyXS
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(20),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusFull),
                        ),
                        child: Text(
                          'Active',
                          style: AppTextStyles.bodyXS
                              .copyWith(color: AppColors.success),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${listing.pricePerNight.toInt()}/night',
                        style: AppTextStyles.labelSM.copyWith(
                            color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 280 + index * 60))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.04, end: 0, duration: 400.ms);
  }
}

// ── Empty Listings ─────────────────────────────────────────────────────────

class _EmptyListings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.home_work_outlined,
              size: 56, color: AppColors.border),
          const SizedBox(height: AppDimensions.spaceLG),
          Text('No listings yet', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            'Create your first listing to start earning.',
            style: AppTextStyles.bodyMD
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.space2XL),
          AppButton(
            label: 'Create a listing',
            onPressed: () => context.push(AppRoutes.hostCreateListing),
          ),
        ],
      ),
    );
  }
}
