import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../booking/application/booking_notifier.dart';
import '../../../booking/domain/entities/booking_entity.dart';

class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() =>
      _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history =
        ref.read(bookingProvider.notifier).bookingHistory;

    final upcoming = history
        .where((b) =>
            b.status == BookingStatus.confirmed ||
            b.status == BookingStatus.pending)
        .toList();
    final completed =
        history.where((b) => b.status == BookingStatus.completed).toList();
    final cancelled =
        history.where((b) => b.status == BookingStatus.cancelled).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 1,
        title: Text('My trips', style: AppTextStyles.h2),
        bottom: history.isEmpty
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: TabBar(
                  controller: _tabController,
                  labelStyle:
                      AppTextStyles.labelSM.copyWith(fontSize: 13),
                  unselectedLabelStyle:
                      AppTextStyles.bodyMD.copyWith(fontSize: 13),
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2,
                  tabs: const [
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Completed'),
                    Tab(text: 'Cancelled'),
                  ],
                ),
              ),
      ),
      body: history.isEmpty
          ? const _EmptyTrips()
          : TabBarView(
              controller: _tabController,
              children: [
                _TripsList(bookings: upcoming, emptyLabel: 'No upcoming trips'),
                _TripsList(
                    bookings: completed, emptyLabel: 'No completed trips'),
                _TripsList(
                    bookings: cancelled, emptyLabel: 'No cancelled trips'),
              ],
            ),
    );
  }
}

// ── Trips List ────────────────────────────────────────────────────────────────

class _TripsList extends StatelessWidget {
  const _TripsList({required this.bookings, required this.emptyLabel});
  final List<BookingEntity> bookings;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return _TabEmptyState(label: emptyLabel);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingPage,
        AppDimensions.spaceLG,
        AppDimensions.paddingPage,
        AppDimensions.space3XL,
      ),
      itemCount: bookings.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppDimensions.spaceLG),
      itemBuilder: (_, i) => _TripCard(booking: bookings[i], index: i),
    );
  }
}

// ── Trip Card ─────────────────────────────────────────────────────────────────

class _TripCard extends StatelessWidget {
  const _TripCard({required this.booking, required this.index});
  final BookingEntity booking;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.push(AppRoutes.listingDetailPath(booking.listingId)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero image ────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusLG)),
              child: Stack(
                children: [
                  AppImage(
                    url: booking.listingThumbnail,
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  // Status pill over image
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _StatusBadge(status: booking.status),
                  ),
                ],
              ),
            ),

            // ── Content ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingCard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    booking.listingTitle,
                    style: AppTextStyles.labelLG,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  // Location
                  Row(
                    children: [
                      Icon(PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                          size: 12, color: AppColors.primary),
                      const SizedBox(width: 3),
                      Text(
                        booking.listingCity,
                        style: AppTextStyles.bodyXS
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spaceMD),
                  const Divider(height: 1),
                  const SizedBox(height: AppDimensions.spaceMD),

                  // Dates + price row
                  Row(
                    children: [
                      // Dates
                      Expanded(
                        child: _InfoCell(
                          icon: PhosphorIcons.calendarBlank(),
                          label: 'Dates',
                          value: booking.formattedDates,
                        ),
                      ),
                      Container(
                          width: 1,
                          height: 36,
                          color: AppColors.border),
                      const SizedBox(width: AppDimensions.spaceMD),
                      // Duration
                      Expanded(
                        child: _InfoCell(
                          icon: PhosphorIcons.moon(),
                          label: 'Duration',
                          value:
                              '${booking.nights} night${booking.nights > 1 ? 's' : ''}',
                        ),
                      ),
                      Container(
                          width: 1,
                          height: 36,
                          color: AppColors.border),
                      const SizedBox(width: AppDimensions.spaceMD),
                      // Price
                      Expanded(
                        child: _InfoCell(
                          icon: PhosphorIcons.currencyDollar(),
                          label: 'Total',
                          value: '\$${booking.totalPrice.toInt()}',
                          valueColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  // Action button for confirmed bookings
                  if (booking.status == BookingStatus.confirmed) ...[
                    const SizedBox(height: AppDimensions.spaceMD),
                    _ViewDetailsButton(
                      onTap: () => context.push(
                          AppRoutes.listingDetailPath(booking.listingId)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: 60 * index))
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.06, end: 0),
    );
  }
}

// ── Info Cell ─────────────────────────────────────────────────────────────────

class _InfoCell extends StatelessWidget {
  const _InfoCell({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: AppColors.textTertiary),
            const SizedBox(width: 3),
            Text(label,
                style:
                    AppTextStyles.caption.copyWith(letterSpacing: 0)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.labelSM.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            letterSpacing: 0,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ── View Details Button ───────────────────────────────────────────────────────

class _ViewDetailsButton extends StatelessWidget {
  const _ViewDetailsButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.primaryLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'View details',
              style: AppTextStyles.labelSM.copyWith(
                color: AppColors.primary,
                letterSpacing: 0,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(PhosphorIcons.arrowRight(),
                size: 14, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, bg, icon) = switch (status) {
      BookingStatus.confirmed => (
          'Confirmed',
          AppColors.success,
          AppColors.success.withAlpha(30),
          PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
        ),
      BookingStatus.pending => (
          'Pending',
          AppColors.warning,
          AppColors.warning.withAlpha(30),
          PhosphorIcons.clockCounterClockwise(),
        ),
      BookingStatus.cancelled => (
          'Cancelled',
          AppColors.error,
          AppColors.error.withAlpha(30),
          PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
        ),
      BookingStatus.completed => (
          'Completed',
          AppColors.textSecondary,
          Colors.black.withAlpha(40),
          PhosphorIcons.flag(PhosphorIconsStyle.fill),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab Empty State ───────────────────────────────────────────────────────────

class _TabEmptyState extends StatelessWidget {
  const _TabEmptyState({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: AppTextStyles.bodyMD.copyWith(color: AppColors.textTertiary),
      ),
    );
  }
}

// ── Empty Trips (no bookings at all) ─────────────────────────────────────────

class _EmptyTrips extends StatelessWidget {
  const _EmptyTrips();

  static const _suggestions = [
    (
      icon: PhosphorIconsStyle.regular,
      name: 'Lagos',
      tag: 'Trending',
      tagColor: Color(0xFFEC4899),
    ),
    (
      icon: PhosphorIconsStyle.regular,
      name: 'Accra',
      tag: 'Popular',
      tagColor: Color(0xFF14B8A6),
    ),
    (
      icon: PhosphorIconsStyle.regular,
      name: 'Nairobi',
      tag: 'New',
      tagColor: Color(0xFF6366F1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingPage,
        AppDimensions.space2XL,
        AppDimensions.paddingPage,
        AppDimensions.space3XL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero illustration ─────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryLight,
                        AppColors.primarySurface,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(40),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    PhosphorIcons.airplaneTakeoff(PhosphorIconsStyle.fill),
                    size: 48,
                    color: AppColors.primary,
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceXL),

                Text(
                  'No trips yet',
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 150.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: AppDimensions.spaceSM),

                Text(
                  'Your upcoming and past stays will\nappear here once you book.',
                  style: AppTextStyles.bodyMD.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 220.ms)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceXL),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.search),
                    icon: Icon(PhosphorIcons.magnifyingGlass(), size: 18),
                    label: const Text('Find a stay'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                    ),
                  ),
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.space3XL),

          // ── Where to next ─────────────────────────────────────────────
          Text('Where to next?', style: AppTextStyles.h3)
              .animate(delay: 400.ms)
              .fadeIn(duration: 400.ms),

          const SizedBox(height: AppDimensions.spaceSM),

          Text(
            'Explore top destinations across West Africa',
            style:
                AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
          )
              .animate(delay: 450.ms)
              .fadeIn(duration: 400.ms),

          const SizedBox(height: AppDimensions.spaceLG),

          // Destination chips
          Row(
            children: [
              _DestinationChip(city: 'Lagos', tag: 'Trending', tagColor: const Color(0xFFEC4899)),
              const SizedBox(width: AppDimensions.spaceSM),
              _DestinationChip(city: 'Accra', tag: 'Popular', tagColor: AppColors.primary),
              const SizedBox(width: AppDimensions.spaceSM),
              _DestinationChip(city: 'Nairobi', tag: 'New', tagColor: const Color(0xFF6366F1)),
            ],
          )
              .animate(delay: 500.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: AppDimensions.space2XL),

          // ── Travel tips ───────────────────────────────────────────────
          Text('Travel tips', style: AppTextStyles.h3)
              .animate(delay: 560.ms)
              .fadeIn(duration: 400.ms),

          const SizedBox(height: AppDimensions.spaceLG),

          ..._buildTips(context),
        ],
      ),
    );
  }

  List<Widget> _buildTips(BuildContext context) {
    final tips = [
      (
        icon: PhosphorIcons.identificationCard(PhosphorIconsStyle.fill),
        color: const Color(0xFF6366F1),
        bg: const Color(0xFFEEF2FF),
        title: 'Verify your ID first',
        body: 'Upload your Ghana Card, NIN, or Passport to unlock instant booking.',
        delay: 620,
      ),
      (
        icon: PhosphorIcons.calendarCheck(PhosphorIconsStyle.fill),
        color: AppColors.primary,
        bg: AppColors.primarySurface,
        title: 'Book early for best prices',
        body: 'Properties in Lagos & Accra fill up fast — reserve 2+ weeks ahead.',
        delay: 680,
      ),
      (
        icon: PhosphorIcons.chatCircleDots(PhosphorIconsStyle.fill),
        color: const Color(0xFFEC4899),
        bg: const Color(0xFFFDF2F8),
        title: 'Message your host',
        body: 'Ask about check-in, parking, or local recommendations before you arrive.',
        delay: 740,
      ),
    ];

    return tips
        .map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
            child: _TipCard(
              icon: t.icon,
              iconColor: t.color,
              iconBg: t.bg,
              title: t.title,
              body: t.body,
            )
                .animate(delay: Duration(milliseconds: t.delay))
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.08, end: 0),
          ),
        )
        .toList();
  }
}

// ── Destination Chip ──────────────────────────────────────────────────────────

class _DestinationChip extends StatelessWidget {
  const _DestinationChip({
    required this.city,
    required this.tag,
    required this.tagColor,
  });
  final String city;
  final String tag;
  final Color tagColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.searchResultsPath(city)),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceMD, vertical: AppDimensions.spaceSM),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tagColor.withAlpha(25),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  tag,
                  style: AppTextStyles.caption.copyWith(
                    color: tagColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                city,
                style: AppTextStyles.labelSM.copyWith(
                  color: AppColors.textPrimary,
                  letterSpacing: 0,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    'Explore',
                    style: AppTextStyles.bodyXS
                        .copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(width: 2),
                  Icon(PhosphorIcons.arrowRight(),
                      size: 10, color: AppColors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tip Card ──────────────────────────────────────────────────────────────────

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelMD),
                const SizedBox(height: 3),
                Text(
                  body,
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
