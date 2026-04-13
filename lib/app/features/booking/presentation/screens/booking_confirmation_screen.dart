import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../application/booking_notifier.dart';
import '../../application/booking_state.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.read(bookingProvider);
    final booking = state is BookingConfirmed ? state.booking : null;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingPage),
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.space2XL),

              // Success icon
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 60,
                  color: AppColors.primary,
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: AppDimensions.spaceXXL),

              Text(
                'Booking confirmed!',
                style: AppTextStyles.h1,
                textAlign: TextAlign.center,
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppDimensions.spaceMD),

              Text(
                'Your reservation is confirmed.\nHave an amazing trip!',
                style: AppTextStyles.bodyLG.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

              if (booking != null) ...[
                const SizedBox(height: AppDimensions.space2XL),
                _BookingDetailsCard(booking: booking)
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 400.ms),
              ],

              const SizedBox(height: AppDimensions.spaceXXL),

              // Escrow banner
              _EscrowInfoCard()
                  .animate(delay: 600.ms)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: AppDimensions.spaceXXL),

              // ID verification reminder
              _IdVerificationReminder(context: context)
                  .animate(delay: 700.ms)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: AppDimensions.space2XL),

              AppButton(
                label: 'View my trips',
                onPressed: () {
                  ref.read(bookingProvider.notifier).reset();
                  context.go(AppRoutes.trips);
                },
              ).animate(delay: 800.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: AppDimensions.spaceMD),

              AppButton(
                label: 'Back to explore',
                variant: AppButtonVariant.outline,
                onPressed: () {
                  ref.read(bookingProvider.notifier).reset();
                  context.go(AppRoutes.home);
                },
              ).animate(delay: 900.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: AppDimensions.space2XL),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingDetailsCard extends StatelessWidget {
  const _BookingDetailsCard({required this.booking});
  final dynamic booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingCard),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _ConfirmRow(label: 'Property', value: booking.listingTitle),
          const Divider(height: AppDimensions.spaceXXL),
          _ConfirmRow(label: 'Dates', value: booking.formattedDates),
          const Divider(height: AppDimensions.spaceXXL),
          _ConfirmRow(
            label: 'Guests',
            value: '${booking.guests} guest${booking.guests > 1 ? 's' : ''}',
          ),
          const Divider(height: AppDimensions.spaceXXL),
          _ConfirmRow(
            label: 'Total paid',
            value: '\$${booking.totalPrice.toInt()}',
            valueStyle: AppTextStyles.priceMD,
          ),
        ],
      ),
    );
  }
}

class _EscrowInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4F1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: const Color(0xFF2D9E8F).withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_rounded, color: Color(0xFF2D9E8F), size: 20),
              const SizedBox(width: AppDimensions.spaceSM),
              Text(
                'Your payment is protected',
                style: AppTextStyles.labelMD.copyWith(color: const Color(0xFF1A6B5E)),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          Text(
            'Your funds are held securely in escrow and will only be released to the host after you check in.',
            style: AppTextStyles.bodyMD.copyWith(color: const Color(0xFF1A6B5E)),
          ),
          const SizedBox(height: AppDimensions.spaceLG),
          _EscrowStep(
            step: '1',
            title: 'Payment received',
            subtitle: 'Your payment is held securely',
            isActive: true,
          ),
          _EscrowStep(
            step: '2',
            title: 'Check-in day',
            subtitle: 'Verify the property with the host',
            isActive: false,
          ),
          _EscrowStep(
            step: '3',
            title: 'Funds released',
            subtitle: 'Host receives payment after 24–48 hrs',
            isActive: false,
          ),
        ],
      ),
    );
  }
}

class _EscrowStep extends StatelessWidget {
  const _EscrowStep({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.isActive,
  });
  final String step;
  final String title;
  final String subtitle;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF2D9E8F) : const Color(0xFF2D9E8F).withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: AppTextStyles.labelSM.copyWith(
                  color: isActive ? Colors.white : const Color(0xFF2D9E8F),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.labelSM.copyWith(color: const Color(0xFF1A6B5E))),
                Text(subtitle,
                    style: AppTextStyles.bodyXS.copyWith(color: const Color(0xFF2D9E8F))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IdVerificationReminder extends StatelessWidget {
  const _IdVerificationReminder({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext outerContext) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.primary.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(Icons.badge_rounded, color: AppColors.primaryDark, size: 24),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete ID verification',
                  style: AppTextStyles.labelMD.copyWith(color: AppColors.primaryDark),
                ),
                const SizedBox(height: 3),
                Text(
                  'A government-issued ID is required at check-in. Verify now to avoid delays.',
                  style: AppTextStyles.bodyXS.copyWith(color: AppColors.primaryDark),
                ),
                const SizedBox(height: AppDimensions.spaceSM),
                GestureDetector(
                  onTap: () => outerContext.push(AppRoutes.idVerification),
                  child: Text(
                    'Verify my ID →',
                    style: AppTextStyles.labelSM.copyWith(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
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

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary)),
        Flexible(
          child: Text(
            value,
            style: valueStyle ?? AppTextStyles.labelMD,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
