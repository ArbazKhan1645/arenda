import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/app_rating_bar.dart';
import '../../domain/entities/listing_entity.dart';
import '../../../wishlist/application/wishlist_notifier.dart';

class ListingCardWidget extends ConsumerWidget {
  const ListingCardWidget({
    super.key,
    required this.listing,
    this.index = 0,
  });

  final ListingEntity listing;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWishlisted = ref.watch(
      wishlistProvider.select((list) => list.any((l) => l.id == listing.id)),
    );

    return GestureDetector(
      onTap: () => context.push(AppRoutes.listingDetailPath(listing.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ──────────────────────────────────────────────────────
          Stack(
            children: [
              AppImage(
                url: listing.thumbnailUrl,
                height: AppDimensions.listingCardImageHeight,
                width: double.infinity,
                borderRadius: BorderRadius.circular(AppDimensions.listingCardRadius),
              ),

              // Wishlist button
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => ref
                      .read(wishlistProvider.notifier)
                      .toggle(listing),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withAlpha(40),
                    ),
                    child: Icon(
                      isWishlisted
                          ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                          : PhosphorIcons.heart(),
                      size: 18,
                      color: isWishlisted ? AppColors.error : Colors.white,
                    ),
                  ),
                ),
              ),

              // Badges
              if (listing.isNew)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Text(
                      'New',
                      style: AppTextStyles.labelSM.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),

              if (listing.discountPercent > 0)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Text(
                      '${listing.discountPercent}% off',
                      style: AppTextStyles.labelSM.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppDimensions.spaceMD),

          // ── Info ───────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${listing.city}, ${listing.country}',
                      style: AppTextStyles.labelMD,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      listing.title,
                      style: AppTextStyles.bodyMD.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (listing.discountPercent > 0) ...[
                          Text(
                            'CFA ${(listing.pricePerNight * 600).toInt()}',
                            style: AppTextStyles.bodyMD.copyWith(
                              color: AppColors.textTertiary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'CFA ${(listing.discountedPrice * 600).toInt()}',
                            style: AppTextStyles.priceMD,
                          ),
                        ] else
                          Text(
                            'CFA ${(listing.pricePerNight * 600).toInt()}',
                            style: AppTextStyles.priceMD,
                          ),
                        Text(
                          ' / nuit',
                          style: AppTextStyles.bodyMD.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spaceSM),
              AppRatingBar(rating: listing.rating),
            ],
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 60 * index)).fadeIn(duration: 400.ms);
  }
}
