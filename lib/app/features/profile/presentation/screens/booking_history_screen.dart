import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../booking/application/booking_notifier.dart';
import '../../../booking/domain/entities/booking_entity.dart';

class BookingHistoryScreen extends ConsumerWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(bookingProvider.notifier);
    final history = notifier.bookingHistory;

    return Scaffold(
      appBar: AppBar(title: const Text('My trips')),
      body: history.isEmpty
          ? _EmptyTrips()
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.paddingPage),
              itemCount: history.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.spaceLG),
              itemBuilder: (_, i) => _TripCard(booking: history[i], index: i),
            ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.booking, required this.index});
  final BookingEntity booking;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.listingDetailPath(booking.listingId)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusLG),
              ),
              child: AppImage(
                url: booking.listingThumbnail,
                height: 160,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingCard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(booking.listingTitle,
                            style: AppTextStyles.labelMD,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      _StatusBadge(status: booking.status),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceXS),
                  Text(booking.listingCity,
                      style: AppTextStyles.bodyMD
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: AppDimensions.spaceSM),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(booking.formattedDates, style: AppTextStyles.bodyMD),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceXS),
                  Text(
                    '${booking.nights} night${booking.nights > 1 ? 's' : ''} · \$${booking.totalPrice.toInt()} total',
                    style: AppTextStyles.bodyMD
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: 60 * index))
          .fadeIn(duration: 400.ms),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      BookingStatus.confirmed => (AppColors.success, AppColors.successLight),
      BookingStatus.pending => (AppColors.warning, AppColors.warningLight),
      BookingStatus.cancelled => (AppColors.error, AppColors.errorLight),
      BookingStatus.completed => (AppColors.textSecondary, AppColors.surface),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        switch (status) {
          BookingStatus.confirmed => 'Confirmed',
          BookingStatus.pending => 'Pending',
          BookingStatus.cancelled => 'Cancelled',
          BookingStatus.completed => 'Completed',
        },
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyTrips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.luggage_outlined, size: 64, color: AppColors.border),
          const SizedBox(height: AppDimensions.spaceLG),
          Text('No trips yet', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            'When you book a stay, it will appear here',
            style:
                AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
