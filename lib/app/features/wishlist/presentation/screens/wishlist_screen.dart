import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/app_rating_bar.dart';
import '../../application/wishlist_notifier.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlisted = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlists')),
      body: wishlisted.isEmpty
          ? _EmptyWishlist()
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.paddingPage),
              itemCount: wishlisted.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.spaceXXL),
              itemBuilder: (context, i) {
                final listing = wishlisted[i];
                return GestureDetector(
                  onTap: () =>
                      context.push(AppRoutes.listingDetailPath(listing.id)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppImage(
                        url: listing.thumbnailUrl,
                        width: 100,
                        height: 100,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMD),
                      ),
                      const SizedBox(width: AppDimensions.spaceMD),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${listing.city}, ${listing.country}',
                              style: AppTextStyles.labelMD,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              listing.title,
                              style: AppTextStyles.bodyMD.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            AppRatingBar(rating: listing.rating),
                            const SizedBox(height: 4),
                            Text(
                              '\$${listing.pricePerNight.toInt()} / night',
                              style: AppTextStyles.priceMD,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_rounded,
                            color: AppColors.error),
                        onPressed: () =>
                            ref.read(wishlistProvider.notifier).toggle(listing),
                      ),
                    ],
                  ),
                )
                    .animate(delay: Duration(milliseconds: 60 * i))
                    .fadeIn(duration: 400.ms);
              },
            ),
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_border_rounded,
              size: 64, color: AppColors.border),
          const SizedBox(height: AppDimensions.spaceLG),
          Text('No saved properties yet', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            'Start exploring and save your favorites',
            style:
                AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
