import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:arenda/app/core/routes/app_routes.dart';
import 'package:arenda/app/core/theme/app_colors.dart';
import 'package:arenda/app/core/theme/app_dimensions.dart';
import 'package:arenda/app/core/theme/app_text_styles.dart';
import 'package:arenda/app/shared/widgets/app_button.dart';
import 'package:arenda/app/shared/widgets/app_image.dart';
import 'package:arenda/app/features/home/data/datasources/mock_home_datasource.dart';
import 'package:arenda/app/features/home/domain/entities/listing_entity.dart';
import 'package:arenda/app/features/booking/application/booking_notifier.dart';
import 'package:arenda/app/features/booking/application/booking_state.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key, required this.listingId});
  final String listingId;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  late ListingEntity? _listing;

  @override
  void initState() {
    super.initState();
    _listing = MockHomeDataSource.getListingById(widget.listingId);
    if (_listing != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(bookingProvider.notifier).startBooking(_listing!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_listing == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Not found')),
      );
    }

    final bookingState = ref.watch(bookingProvider);

    ref.listen(bookingProvider, (_, next) {
      if (next is BookingConfirmed) {
        final listing = _listing!;
        final booking = next.booking;
        context.pop();
        context.push(
          AppRoutes.payment,
          extra: {
            'listingTitle': listing.title,
            'totalUSD': booking.totalPrice,
            'nights': booking.nights,
            'localCurrency': listing.localCurrency,
            'localTotal': listing.localPricePerNight != null
                ? (listing.effectiveLocalPrice * booking.nights)
                : booking.totalPrice,
          },
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request to book'),
        leading: IconButton(
          icon: Icon(PhosphorIcons.x()),
          onPressed: () {
            ref.read(bookingProvider.notifier).reset();
            context.pop();
          },
        ),
      ),
      body: bookingState is BookingSelecting
          ? _BookingForm(
              listing: _listing!,
              state: bookingState,
              onDatesChanged: (ci, co) =>
                  ref.read(bookingProvider.notifier).setDates(ci, co),
              onGuestsChanged: (g) =>
                  ref.read(bookingProvider.notifier).setGuests(g),
            )
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: bookingState is BookingSelecting
          ? _BookingBottomBar(
              state: bookingState,
              isLoading: bookingState is BookingLoading,
              onConfirm: () =>
                  ref.read(bookingProvider.notifier).confirmBooking(),
            )
          : null,
    );
  }
}

class _BookingForm extends StatelessWidget {
  const _BookingForm({
    required this.listing,
    required this.state,
    required this.onDatesChanged,
    required this.onGuestsChanged,
  });

  final ListingEntity listing;
  final BookingSelecting state;
  final Function(DateTime, DateTime) onDatesChanged;
  final ValueChanged<int> onGuestsChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      children: [
        // Listing summary
        _ListingSummary(listing: listing).animate().fadeIn(duration: 400.ms),

        const SizedBox(height: AppDimensions.spaceXXL),
        const Divider(),
        const SizedBox(height: AppDimensions.spaceXXL),

        // Dates
        Text('Your trip', style: AppTextStyles.h3),
        const SizedBox(height: AppDimensions.spaceLG),

        _TripDateRow(
          state: state,
          onTap: () async {
            final range = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: Theme.of(
                    ctx,
                  ).colorScheme.copyWith(primary: AppColors.primary),
                ),
                child: child!,
              ),
            );
            if (range != null) onDatesChanged(range.start, range.end);
          },
        ),

        const SizedBox(height: AppDimensions.spaceLG),

        // Guests
        _GuestRow(guests: state.guests, onChanged: onGuestsChanged),

        const SizedBox(height: AppDimensions.spaceXXL),
        const Divider(),
        const SizedBox(height: AppDimensions.spaceXXL),

        // ID verification notice
        _IdVerificationNotice(),

        const SizedBox(height: AppDimensions.spaceXXL),
        const Divider(),
        const SizedBox(height: AppDimensions.spaceXXL),

        // Price breakdown
        if (state.canBook) ...[
          Text('Price details', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.spaceLG),
          _PriceRow(
            label:
                '\$${listing.discountedPrice.toInt()} × ${state.nights} nights',
            value: state.subtotal,
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          _PriceRow(label: 'Cleaning fee', value: listing.cleaningFee),
          const SizedBox(height: AppDimensions.spaceSM),
          _PriceRow(label: 'Service fee', value: listing.serviceFee),
          if (listing.tourismLevyPercent > 0) ...[
            const SizedBox(height: AppDimensions.spaceSM),
            _PriceRow(
              label: 'Tourism levy (${listing.tourismLevyPercent.toInt()}%)',
              value: listing.tourismLevy(state.nights),
              isSubtle: true,
            ),
          ],
          const Divider(height: AppDimensions.spaceXXL),
          _PriceRow(
            label: 'Total (USD)',
            value: listing.totalForNights(state.nights),
            isTotal: true,
          ),
          if (listing.localPricePerNight != null &&
              listing.localCurrency != 'USD') ...[
            const SizedBox(height: AppDimensions.spaceSM),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '≈ Local equivalent',
                  style: AppTextStyles.bodyMD.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${listing.localCurrencySymbol}${(listing.effectiveLocalPrice * state.nights).toStringAsFixed(0)} ${listing.localCurrency}',
                  style: AppTextStyles.labelMD.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ],
        ],

        const SizedBox(height: AppDimensions.space3XL),
      ],
    );
  }
}

class _ListingSummary extends StatelessWidget {
  const _ListingSummary({required this.listing});
  final ListingEntity listing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppImage(
          url: listing.thumbnailUrl,
          width: 80,
          height: 80,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        const SizedBox(width: AppDimensions.spaceMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                listing.city,
                style: AppTextStyles.bodyMD.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                listing.title,
                style: AppTextStyles.labelMD,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    PhosphorIcons.star(PhosphorIconsStyle.fill),
                    size: 12,
                    color: AppColors.star,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${listing.rating}',
                    style: AppTextStyles.bodyXS.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TripDateRow extends StatelessWidget {
  const _TripDateRow({required this.state, required this.onTap});
  final BookingSelecting state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingCard),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: Row(
          children: [
            Icon(
              PhosphorIcons.calendarBlank(),
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppDimensions.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dates', style: AppTextStyles.labelSM),
                  Text(
                    state.checkIn != null && state.checkOut != null
                        ? '${fmt.format(state.checkIn!)} – ${fmt.format(state.checkOut!)}'
                        : 'Select dates',
                    style: AppTextStyles.bodyMD,
                  ),
                ],
              ),
            ),
            Icon(PhosphorIcons.caretRight(), color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _GuestRow extends StatelessWidget {
  const _GuestRow({required this.guests, required this.onChanged});
  final int guests;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingCard),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.usersThree(),
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Guests', style: AppTextStyles.labelSM),
                Text(
                  '$guests guest${guests > 1 ? 's' : ''}',
                  style: AppTextStyles.bodyMD,
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: guests > 1 ? () => onChanged(guests - 1) : null,
                icon: Icon(
                  PhosphorIcons.minusCircle(),
                  color: guests > 1 ? AppColors.textPrimary : AppColors.border,
                ),
              ),
              Text('$guests', style: AppTextStyles.labelMD),
              IconButton(
                onPressed: () => onChanged(guests + 1),
                icon: Icon(
                  PhosphorIcons.plusCircle(),
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.isSubtle = false,
  });
  final String label;
  final double value;
  final bool isTotal;
  final bool isSubtle;

  @override
  Widget build(BuildContext context) {
    final labelStyle = isTotal
        ? AppTextStyles.labelLG
        : isSubtle
        ? AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary)
        : AppTextStyles.bodyLG;
    final valueStyle = isTotal ? AppTextStyles.priceLG : labelStyle;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text('\$${value.toInt()}', style: valueStyle),
      ],
    );
  }
}

class _IdVerificationNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.primary.withAlpha(80)),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
            color: AppColors.primaryDark,
            size: 24,
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID verification required',
                  style: AppTextStyles.labelMD.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'A government-issued ID (Ghana Card, NIN, Passport) is required before check-in.',
                  style: AppTextStyles.bodyXS.copyWith(
                    color: AppColors.primaryDark,
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

class _BookingBottomBar extends StatelessWidget {
  const _BookingBottomBar({
    required this.state,
    required this.isLoading,
    required this.onConfirm,
  });
  final BookingSelecting state;
  final bool isLoading;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.paddingPage,
        AppDimensions.spaceLG,
        AppDimensions.paddingPage,
        MediaQuery.of(context).padding.bottom + AppDimensions.spaceLG,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.canBook)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: AppTextStyles.labelLG),
                  Text(
                    '\$${state.total.toInt()}',
                    style: AppTextStyles.priceLG,
                  ),
                ],
              ),
            ),
          AppButton(
            label: 'Proceed to payment',
            onPressed: state.canBook ? onConfirm : null,
            isLoading: isLoading,
            isDisabled: !state.canBook,
          ),
        ],
      ),
    );
  }
}
