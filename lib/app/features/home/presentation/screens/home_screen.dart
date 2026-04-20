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
import '../../../../shared/widgets/app_shimmer.dart';
import '../../application/home_notifier.dart';
import '../../application/home_state.dart';
import '../widgets/listing_card_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(homeProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            _HomeAppBar(),
            switch (state) {
              HomeLoading() || HomeInitial() => _LoadingSliver(),
              HomeLoaded(:final categories, :final featuredListings) =>
                _ContentSliver(
                  homeState: state,
                  categories: categories,
                  featuredListings: featuredListings,
                  ref: ref,
                ),
              HomeError(:final message) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIcons.warningCircle(),
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppDimensions.spaceMD),
                      Text(message, style: AppTextStyles.bodyMD),
                      const SizedBox(height: AppDimensions.spaceLG),
                      TextButton(
                        onPressed: () =>
                            ref.read(homeProvider.notifier).refresh(),
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              ),
            },
          ],
        ),
      ),
    );
  }
}

// ── App Bar ────────────────────────────────────────────────────────────────

class _HomeAppBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      titleSpacing: AppDimensions.paddingPage,
      title: _SearchBarButton(),
    );
  }
}

class _SearchBarButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.search),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: AppDimensions.spaceLG),
            Icon(
              PhosphorIcons.magnifyingGlass(),
              size: 20,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: AppDimensions.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Anywhere',
                    style: AppTextStyles.labelSM.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
                  Text('Any week · Add guests', style: AppTextStyles.bodyXS),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(6),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.slidersHorizontal(),
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Loading ────────────────────────────────────────────────────────────────

class _LoadingSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      sliver: SliverList.separated(
        itemCount: 4,
        separatorBuilder: (_, _) =>
            const SizedBox(height: AppDimensions.spaceXXL),
        itemBuilder: (_, _) => const ListingCardShimmer(),
      ),
    );
  }
}

// ── Content ────────────────────────────────────────────────────────────────

class _ContentSliver extends StatelessWidget {
  const _ContentSliver({
    required this.homeState,
    required this.categories,
    required this.featuredListings,
    required this.ref,
  });

  final HomeLoaded homeState;
  final List categories;
  final List featuredListings;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        // Category chips
        _CategoryFilterRow(homeState: homeState, ref: ref),

        // Featured section
        if (featuredListings.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingPage,
              AppDimensions.spaceSM,
              AppDimensions.paddingPage,
              AppDimensions.spaceLG,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Featured stays', style: AppTextStyles.h3),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'See all',
                    style: AppTextStyles.labelSM.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
          SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingPage,
              ),
              itemCount: featuredListings.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppDimensions.spaceLG),
              itemBuilder: (context, i) =>
                  _FeaturedCard(listing: featuredListings[i]),
            ),
          ),
        ],

        // All listings
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingPage,
            AppDimensions.spaceSM,
            AppDimensions.paddingPage,
            AppDimensions.spaceLG,
          ),
          child: Text(
            'All stays',
            style: AppTextStyles.h3,
          ).animate().fadeIn(duration: 400.ms),
        ),

        ...List.generate(
          homeState.filteredListings.length,
          (i) => Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingPage,
              0,
              AppDimensions.paddingPage,
              AppDimensions.spaceXXL,
            ),
            child: ListingCardWidget(
              listing: homeState.filteredListings[i],
              index: i,
            ),
          ),
        ),

        SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
      ]),
    );
  }
}

// ── Category Filter Row ────────────────────────────────────────────────────

class _CategoryFilterRow extends StatelessWidget {
  const _CategoryFilterRow({required this.homeState, required this.ref});

  final HomeLoaded homeState;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingPage,
          vertical: 8,
        ),
        itemCount: homeState.categories.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: AppDimensions.spaceSM),
        itemBuilder: (context, i) {
          final cat = homeState.categories[i];
          final isSelected = cat.id == homeState.selectedCategoryId;
          return GestureDetector(
            onTap: () => ref.read(homeProvider.notifier).selectCategory(cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceLG,
                vertical: AppDimensions.spaceSM,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat.icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    cat.label,
                    style: AppTextStyles.labelSM.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Featured Card ──────────────────────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.listing});

  final dynamic listing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.push(AppRoutes.listingDetailPath(listing.id as String)),
      child: SizedBox(
        width: 240,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppImage(
              url: listing.thumbnailUrl as String,
              height: 180,
              width: 240,
              borderRadius: BorderRadius.circular(
                AppDimensions.listingCardRadius,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            Text(
              '${listing.city}, ${listing.country}',
              style: AppTextStyles.labelMD,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  PhosphorIcons.star(PhosphorIconsStyle.fill),
                  size: 12,
                  color: AppColors.star,
                ),
                const SizedBox(width: 3),
                Text(
                  (listing.rating as double).toStringAsFixed(2),
                  style: AppTextStyles.bodyXS.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ' · CFA ${((listing.pricePerNight as double) * 600).toInt()}/nuit',
                  style: AppTextStyles.bodyXS,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
