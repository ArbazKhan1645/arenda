import 'package:arenda/app/features/home/domain/entities/listing_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:arenda/app/core/routes/app_routes.dart';
import 'package:arenda/app/core/theme/app_colors.dart';
import 'package:arenda/app/core/theme/app_dimensions.dart';
import 'package:arenda/app/core/theme/app_text_styles.dart';
import 'package:arenda/app/shared/widgets/app_image.dart';
import 'package:arenda/app/shared/widgets/app_rating_bar.dart';
import 'package:arenda/app/features/wishlist/application/wishlist_notifier.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlisted = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 1,
        title: Text('Wishlists', style: AppTextStyles.h2),
      ),
      body: wishlisted.isEmpty
          ? const _EmptyWishlist()
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.paddingPage,
                    AppDimensions.spaceLG,
                    AppDimensions.paddingPage,
                    AppDimensions.spaceSM,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      '${wishlisted.length} saved ${wishlisted.length == 1 ? 'property' : 'properties'}',
                      style: AppTextStyles.bodyMD.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.paddingPage,
                    0,
                    AppDimensions.paddingPage,
                    AppDimensions.space3XL,
                  ),
                  sliver: SliverList.separated(
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppDimensions.spaceMD),
                    itemCount: wishlisted.length,
                    itemBuilder: (context, i) {
                      final listing = wishlisted[i];
                      return _WishlistCard(
                            listing: listing,
                            onTap: () => context.push(
                              AppRoutes.listingDetailPath(listing.id),
                            ),
                            onRemove: () => ref
                                .read(wishlistProvider.notifier)
                                .toggle(listing),
                          )
                          .animate(delay: Duration(milliseconds: 60 * i))
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.06, end: 0);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Wishlist Card ────────────────────────────────────────────────────────────

class _WishlistCard extends StatelessWidget {
  const _WishlistCard({
    required this.listing,
    required this.onTap,
    required this.onRemove,
  });

  final ListingEntity listing;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusLG),
                bottomLeft: Radius.circular(AppDimensions.radiusLG),
              ),
              child: AppImage(
                url: listing.thumbnailUrl,
                width: 110,
                height: 110,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${listing.city}, ${listing.country}',
                            style: AppTextStyles.labelSM.copyWith(
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.title,
                      style: AppTextStyles.labelMD.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    AppRatingBar(rating: listing.rating),
                    const SizedBox(height: 6),
                    Text(
                      'CFA ${(listing.pricePerNight * 600).toInt()}',
                      style: AppTextStyles.priceMD.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 4),
              child: IconButton(
                icon: Icon(
                  PhosphorIcons.heart(PhosphorIconsStyle.fill),
                  color: AppColors.error,
                  size: 20,
                ),
                onPressed: onRemove,
                tooltip: 'Remove',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────────────

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingPage * 1.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryLight,
                        AppColors.primarySurface,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIcons.heart(PhosphorIconsStyle.fill),
                    size: 44,
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
                  'Nothing saved yet',
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                )
                .animate(delay: 200.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: AppDimensions.spaceSM),

            Text(
              'Tap the heart on any property to save it here for later.',
              style: AppTextStyles.bodyMD.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: AppDimensions.space2XL),

            Builder(
                  builder: (context) => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go(AppRoutes.search),
                      icon: Icon(PhosphorIcons.magnifyingGlass(), size: 18),
                      label: const Text('Explore properties'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSM,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .animate(delay: 400.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}
