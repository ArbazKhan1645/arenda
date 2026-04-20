import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:arenda/app/core/routes/app_routes.dart';
import 'package:arenda/app/core/theme/app_colors.dart';
import 'package:arenda/app/core/theme/app_dimensions.dart';
import 'package:arenda/app/core/theme/app_text_styles.dart';
import 'package:arenda/app/shared/widgets/app_avatar.dart';
import 'package:arenda/app/shared/widgets/app_button.dart';
import 'package:arenda/app/shared/widgets/app_image.dart';
import 'package:arenda/app/shared/widgets/app_rating_bar.dart';
import 'package:arenda/app/features/home/data/datasources/mock_home_datasource.dart';
import 'package:arenda/app/features/home/domain/entities/listing_entity.dart';
import 'package:arenda/app/features/home/domain/entities/review_entity.dart';
import 'package:arenda/app/features/wishlist/application/wishlist_notifier.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  const ListingDetailScreen({super.key, required this.listingId});
  final String listingId;

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  late ListingEntity? _listing;
  late List<ReviewEntity> _reviews;
  int _currentMediaIndex = 0;
  bool _showFullDescription = false;

  final Map<int, VideoPlayerController> _videoControllers = {};
  final Set<int> _initializedVideos = {};

  @override
  void initState() {
    super.initState();
    _listing = MockHomeDataSource.getListingById(widget.listingId);
    _reviews = MockHomeDataSource.getReviews(widget.listingId);
    _maybeInitVideo(0);
  }

  @override
  void dispose() {
    for (final c in _videoControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _maybeInitVideo(int index) async {
    if (_listing == null) return;
    final media = _listing!.media;
    if (index >= media.length || !media[index].isVideo) return;
    if (_videoControllers.containsKey(index)) return;

    final ctrl = VideoPlayerController.networkUrl(Uri.parse(media[index].url));
    _videoControllers[index] = ctrl;
    await ctrl.initialize();
    if (!mounted) return;
    setState(() => _initializedVideos.add(index));
    if (index == _currentMediaIndex) await ctrl.play();
  }

  void _onPageChanged(int i) {
    _videoControllers[_currentMediaIndex]?.pause();
    setState(() => _currentMediaIndex = i);
    _maybeInitVideo(i);
  }

  Widget _buildMediaItem(int i) {
    final item = _listing!.media[i];
    if (item.isVideo) {
      final ctrl = _videoControllers[i];
      final ready = _initializedVideos.contains(i) && ctrl != null;
      if (ready) {
        return GestureDetector(
          onTap: () => setState(() {
            ctrl.value.isPlaying ? ctrl.pause() : ctrl.play();
          }),
          child: Stack(
            fit: StackFit.expand,
            children: [
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: ctrl.value.size.width,
                  height: ctrl.value.size.height,
                  child: VideoPlayer(ctrl),
                ),
              ),
              ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: ctrl,
                builder: (context, val, child) => val.isPlaying
                    ? const SizedBox.shrink()
                    : Container(
                        color: Colors.black38,
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_outline_rounded,
                            color: Colors.white,
                            size: 64,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      }
      // Loading state — show thumbnail while controller initialises
      return Stack(
        fit: StackFit.expand,
        children: [
          AppImage(url: item.effectiveThumbnail),
          const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      );
    }
    return AppImage(url: item.url);
  }

  @override
  Widget build(BuildContext context) {
    if (_listing == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Listing not found')),
      );
    }

    final listing = _listing!;
    final isWishlisted = ref.watch(
      wishlistProvider.select((l) => l.any((x) => x.id == listing.id)),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Image Slider ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 8),
                  ],
                ),
                child: Icon(
                  PhosphorIcons.arrowLeft(),
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () =>
                    ref.read(wishlistProvider.notifier).toggle(listing),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    isWishlisted
                        ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                        : PhosphorIcons.heart(),
                    color: isWishlisted
                        ? AppColors.error
                        : AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 8),
                  ],
                ),
                child: Icon(
                  PhosphorIcons.shareNetwork(),
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    itemCount: listing.media.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (_, i) => _buildMediaItem(i),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        listing.media.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _currentMediaIndex == i ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentMediaIndex == i
                                ? Colors.white
                                : Colors.white54,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingPage,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppDimensions.spaceXL),

                // Title & Rating
                Text(
                  listing.title,
                  style: AppTextStyles.h2,
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: AppDimensions.spaceSM),
                Row(
                  children: [
                    AppRatingBar(
                      rating: listing.rating,
                      showLabel: true,
                      reviewCount: listing.reviewCount,
                    ),
                    const SizedBox(width: AppDimensions.spaceSM),
                    const Text('·'),
                    const SizedBox(width: AppDimensions.spaceSM),
                    Text(
                      listing.location.address,
                      style: AppTextStyles.bodyMD.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spaceSM),
                const Divider(),
                const SizedBox(height: AppDimensions.spaceSM),

                // Verification badges
                if (listing.verificationBadges.isNotEmpty) ...[
                  _VerificationBadges(
                    badges: listing.verificationBadges,
                  ).animate(delay: 80.ms).fadeIn(duration: 400.ms),
                  const SizedBox(height: AppDimensions.spaceLG),
                  const Divider(),
                  const SizedBox(height: AppDimensions.spaceLG),
                ],

                // Host
                _HostSection(listing: listing),

                const SizedBox(height: AppDimensions.spaceLG),
                const Divider(),
                const SizedBox(height: AppDimensions.spaceMD),

                // Property stats
                _StatsRow(listing: listing),

                const SizedBox(height: AppDimensions.spaceMD),
                const Divider(),
                const SizedBox(height: AppDimensions.spaceXL),

                // Description
                _DescriptionSection(
                  description: listing.description,
                  showFull: _showFullDescription,
                  onToggle: () => setState(
                    () => _showFullDescription = !_showFullDescription,
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceXL),
                const Divider(),
                const SizedBox(height: AppDimensions.spaceXL),

                // Amenities
                _AmenitiesSection(amenities: listing.amenities),

                const SizedBox(height: AppDimensions.spaceXL),
                const Divider(),
                const SizedBox(height: AppDimensions.spaceXL),

                // Reviews
                _ReviewsSection(
                  reviews: _reviews,
                  rating: listing.rating,
                  reviewCount: listing.reviewCount,
                  listingId: listing.id,
                ),

                const SizedBox(height: AppDimensions.spaceXL),
                const Divider(),
                const SizedBox(height: AppDimensions.spaceXL),

                // Map placeholder
                _MapSection(listing: listing),

                const SizedBox(height: AppDimensions.spaceXL),
                const Divider(),
                const SizedBox(height: AppDimensions.spaceXL),

                // Landmark navigation
                _LandmarkSection(listing: listing),

                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),

      // ── Bottom Reserve Bar ─────────────────────────────────────────────
      bottomNavigationBar: _ReserveBar(listing: listing),
    );
  }
}

// ── Host Section ───────────────────────────────────────────────────────────

class _HostSection extends StatelessWidget {
  const _HostSection({required this.listing});
  final ListingEntity listing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppAvatar(
          imageUrl: listing.hostAvatarUrl,
          name: listing.hostName,
          size: 52,
          borderColor: AppColors.primary,
          borderWidth: listing.hostIsSuperhost ? 2 : 0,
        ),
        const SizedBox(width: AppDimensions.spaceMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Hosted by ${listing.hostName}',
                    style: AppTextStyles.h4.copyWith(fontSize: 12),
                  ),
                  if (listing.hostIsSuperhost) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull,
                        ),
                      ),
                      child: Text(
                        'Superhost',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                '${listing.reviewCount} reviews · 4 years hosting',
                style: AppTextStyles.bodyMD.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Stats Row ──────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.listing});
  final ListingEntity listing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Stat(
          icon: PhosphorIcons.usersThree(),
          label: '${listing.maxGuests} guests',
        ),
        _Stat(icon: PhosphorIcons.bed(), label: '${listing.bedrooms} bedrooms'),
        _Stat(icon: PhosphorIcons.bed(), label: '${listing.beds} beds'),
        _Stat(
          icon: PhosphorIcons.bathtub(),
          label: '${listing.bathrooms} baths',
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppColors.textPrimary),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodyXS, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Description ────────────────────────────────────────────────────────────

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({
    required this.description,
    required this.showFull,
    required this.onToggle,
  });
  final String description;
  final bool showFull;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About this place', style: AppTextStyles.h3),
        const SizedBox(height: AppDimensions.spaceMD),
        Text(
          description,
          style: AppTextStyles.bodyMD,
          maxLines: showFull ? null : 4,
          overflow: showFull ? null : TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppDimensions.spaceSM),
        GestureDetector(
          onTap: onToggle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                showFull ? 'Show less' : 'Show more',
                style: AppTextStyles.labelMD.copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
              Icon(
                showFull ? PhosphorIcons.caretUp() : PhosphorIcons.caretDown(),
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Amenities ──────────────────────────────────────────────────────────────

class _AmenitiesSection extends StatelessWidget {
  const _AmenitiesSection({required this.amenities});
  final List<String> amenities;

  static final _amenityMeta = {
    'wifi': (icon: PhosphorIcons.wifiHigh(), label: 'Wifi'),
    'pool': (icon: PhosphorIcons.waves(), label: 'Pool'),
    'kitchen': (icon: PhosphorIcons.forkKnife(), label: 'Kitchen'),
    'parking': (icon: PhosphorIcons.car(), label: 'Free parking'),
    'ac': (icon: PhosphorIcons.snowflake(), label: 'Air conditioning'),
    'beach_access': (icon: PhosphorIcons.umbrella(), label: 'Beach access'),
    'bbq': (icon: PhosphorIcons.fire(), label: 'BBQ grill'),
    'gym': (icon: PhosphorIcons.barbell(), label: 'Gym'),
    'fireplace': (icon: PhosphorIcons.fire(), label: 'Indoor fireplace'),
    'hot_tub': (icon: PhosphorIcons.thermometer(), label: 'Hot tub'),
    'washer': (icon: PhosphorIcons.arrowClockwise(), label: 'Washer'),
    'dryer': (icon: PhosphorIcons.tote(), label: 'Dryer'),
    'heating': (icon: PhosphorIcons.thermometer(), label: 'Heating'),
    'doorman': (icon: PhosphorIcons.shieldCheck(), label: 'Doorman'),
    'breakfast': (icon: PhosphorIcons.coffee(), label: 'Breakfast'),
    'kayak': (icon: PhosphorIcons.waves(), label: 'Kayak'),
    'garden': (icon: PhosphorIcons.tree(), label: 'Garden'),
    'spa': (icon: PhosphorIcons.leaf(), label: 'Spa'),
    'butler': (icon: PhosphorIcons.bellSimple(), label: 'Butler'),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What this place offers', style: AppTextStyles.h3),
        const SizedBox(height: AppDimensions.spaceSM),
        GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(0),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 4,
            crossAxisSpacing: AppDimensions.spaceMD,
            mainAxisSpacing: AppDimensions.spaceMD,
          ),
          itemCount: amenities.length > 8 ? 8 : amenities.length,
          itemBuilder: (_, i) {
            final key = amenities[i];
            final meta = _amenityMeta[key];
            return Row(
              children: [
                Icon(
                  meta?.icon ?? PhosphorIcons.checkCircle(),
                  size: 20,
                  color: AppColors.darkSurfaceVariant,
                ),
                const SizedBox(width: AppDimensions.spaceSM),
                Expanded(
                  child: Text(
                    meta?.label ?? key,
                    style: AppTextStyles.bodySM,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ── Reviews ────────────────────────────────────────────────────────────────

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({
    required this.reviews,
    required this.rating,
    required this.reviewCount,
    required this.listingId,
  });
  final List<ReviewEntity> reviews;
  final double rating;
  final int reviewCount;
  final String listingId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  PhosphorIcons.star(PhosphorIconsStyle.fill),
                  size: 18,
                  color: AppColors.star,
                ),
                const SizedBox(width: 4),
                Text('$rating · $reviewCount reviews', style: AppTextStyles.h3),
              ],
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.reviewsPath(listingId)),
              child: Text(
                'See all',
                style: AppTextStyles.labelSM.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceLG),
        ...reviews.take(3).map((r) => _ReviewTile(review: r)),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});
  final ReviewEntity review;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(
                imageUrl: review.userAvatarUrl,
                name: review.userName,
                size: 40,
              ),
              const SizedBox(width: AppDimensions.spaceMD),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.userName, style: AppTextStyles.labelMD),
                  Text(review.formattedDate, style: AppTextStyles.bodyXS),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          Text(
            review.comment,
            style: AppTextStyles.bodyMD,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Map Placeholder ────────────────────────────────────────────────────────

class _MapSection extends StatelessWidget {
  const _MapSection({required this.listing});
  final ListingEntity listing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Where you\'ll be', style: AppTextStyles.h3),
        const SizedBox(height: AppDimensions.spaceLG),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                child: const AppImage(
                  url:
                      'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=900&q=80',
                  width: double.infinity,
                  height: 200,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 8),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(listing.city, style: AppTextStyles.labelMD),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        Text(
          listing.location.address,
          style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ── Reserve Bar ────────────────────────────────────────────────────────────

class _ReserveBar extends StatelessWidget {
  const _ReserveBar({required this.listing});
  final ListingEntity listing;

  @override
  Widget build(BuildContext context) {
    final hasLocal =
        listing.localPricePerNight != null && listing.localCurrency != 'USD';

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
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${listing.discountedPrice.toInt()}',
                    style: AppTextStyles.priceLG,
                  ),
                  Text(
                    ' / night',
                    style: AppTextStyles.bodyMD.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (hasLocal)
                Text(
                  '≈ ${listing.localCurrencySymbol}${listing.effectiveLocalPrice.toInt()} ${listing.localCurrency}',
                  style: AppTextStyles.bodyXS.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
              AppRatingBar(
                rating: listing.rating,
                size: 12,
                showLabel: true,
                reviewCount: listing.reviewCount,
              ),
            ],
          ),
          const SizedBox(width: AppDimensions.spaceLG),
          Expanded(
            child: AppButton(
              label: 'Reserve',
              onPressed: () => context.push(AppRoutes.bookingPath(listing.id)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Verification Badges ────────────────────────────────────────────────────

class _VerificationBadges extends StatelessWidget {
  const _VerificationBadges({required this.badges});
  final List<String> badges;

  static final _badgeMeta = {
    '24/7 Power': (
      icon: PhosphorIcons.lightning(),
      color: const Color(0xFFFFC107),
    ),
    'Physically Vetted': (
      icon: PhosphorIcons.sealCheck(PhosphorIconsStyle.fill),
      color: const Color(0xFF22C55E),
    ),
    'High-Speed WiFi': (
      icon: PhosphorIcons.wifiHigh(),
      color: const Color(0xFF14B8A6),
    ),
    'CCTV': (icon: PhosphorIcons.video(), color: const Color(0xFF6366F1)),
    'Gated Estate': (
      icon: PhosphorIcons.lock(),
      color: const Color(0xFF0D9488),
    ),
    'Beach Access': (
      icon: PhosphorIcons.umbrella(),
      color: const Color(0xFF0EA5E9),
    ),
    'Concierge': (
      icon: PhosphorIcons.bellSimple(),
      color: const Color(0xFFEC4899),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verified by Arenda', style: AppTextStyles.h4),
        const SizedBox(height: AppDimensions.spaceLG),
        Wrap(
          spacing: AppDimensions.spaceSM,
          runSpacing: AppDimensions.spaceSM,
          children: badges.map((b) {
            final meta = _badgeMeta[b];
            final color = meta?.color ?? AppColors.primary;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                border: Border.all(color: color.withAlpha(80)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    meta?.icon ?? PhosphorIcons.check(),
                    size: 14,
                    color: color,
                  ),
                  const SizedBox(width: 5),
                  Text(b, style: AppTextStyles.labelSM.copyWith(color: color)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Landmark Section ───────────────────────────────────────────────────────

class _LandmarkSection extends StatelessWidget {
  const _LandmarkSection({required this.listing});
  final ListingEntity listing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'How to find this place',
              style: AppTextStyles.h4.copyWith(fontSize: 13),
            ),
            TextButton.icon(
              onPressed: () => context.push(AppRoutes.landmarkPath(listing.id)),
              icon: Icon(PhosphorIcons.mapTrifold(), size: 16),
              label: Text(
                'Full directions',
                style: AppTextStyles.h4.copyWith(fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceSM),
        if (listing.landmarkNote != null) ...[
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceLG),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              border: Border.all(color: const Color(0xFFFFCC02)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🗺️', style: TextStyle(fontSize: 20)),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: Text(
                    listing.landmarkNote!,
                    style: AppTextStyles.bodyMD.copyWith(height: 1.6),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ] else
          Text(
            'Exact directions will be shared after booking is confirmed.',
            style: AppTextStyles.bodyMD.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}
