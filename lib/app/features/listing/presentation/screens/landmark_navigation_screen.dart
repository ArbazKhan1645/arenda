import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../home/data/datasources/mock_home_datasource.dart';
import '../../../home/domain/entities/listing_entity.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LandmarkNavigationScreen extends StatelessWidget {
  const LandmarkNavigationScreen({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context) {
    final listing = MockHomeDataSource.getListingById(listingId);

    if (listing == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('How to find us')),
        body: const Center(child: Text('Listing not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('How to find us'),
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft()),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.shareNetwork()),
            tooltip: 'Share directions',
            onPressed: () => _copyToClipboard(context, listing),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ── Map Placeholder ────────────────────────────────────────
          SliverToBoxAdapter(
            child: _MapPlaceholder(
              listing: listing,
            ).animate().fadeIn(duration: 400.ms),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.paddingPage),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Location Header ──────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMD,
                        ),
                      ),
                      child: Icon(
                        PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                        color: AppColors.primaryDark,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceLG),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(listing.city, style: AppTextStyles.labelLG),
                          Text(
                            listing.location.city,
                            style: AppTextStyles.bodyMD.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.space2XL),
                const Divider(),
                const SizedBox(height: AppDimensions.space2XL),

                // ── Landmark Note ────────────────────────────────────
                Text(
                  'Landmark directions',
                  style: AppTextStyles.h3,
                ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: AppDimensions.spaceSM),
                Text(
                  'Use these directions when GPS is inaccurate or you need to describe to a driver.',
                  style: AppTextStyles.bodyMD.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ).animate(delay: 180.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.spaceLG),

                _LandmarkCard(
                  note:
                      listing.landmarkNote ??
                      'The host will send exact directions after your booking is confirmed.',
                ).animate(delay: 220.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.space2XL),
                const Divider(),
                const SizedBox(height: AppDimensions.space2XL),

                // ── Coordinates (for driver apps) ────────────────────
                Text(
                  'GPS Coordinates',
                  style: AppTextStyles.h3,
                ).animate(delay: 270.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: AppDimensions.spaceSM),
                _CoordinateRow(
                  lat: listing.latitude,
                  lng: listing.longitude,
                ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: AppDimensions.space2XL),
                const Divider(),
                const SizedBox(height: AppDimensions.space2XL),

                // ── Tips ─────────────────────────────────────────────
                Text(
                  'Local tips',
                  style: AppTextStyles.h3,
                ).animate(delay: 340.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: AppDimensions.spaceLG),
                ..._tips.asMap().entries.map(
                  (e) => _TipTile(tip: e.value, delay: 360 + e.key * 60),
                ),

                const SizedBox(height: AppDimensions.space2XL),

                // ── CTA Buttons ──────────────────────────────────────
                AppButton(
                  label: 'Copy directions',
                  variant: AppButtonVariant.outline,
                  prefixIcon: Icon(PhosphorIcons.copy(), size: 18),
                  onPressed: () => _copyToClipboard(context, listing),
                ).animate(delay: 500.ms).fadeIn(duration: 400.ms),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  static const _tips = [
    (
      icon: '🚕',
      text:
          'When taking a taxi/Uber, show the driver this screen with the landmark description.',
    ),
    (
      icon: '📞',
      text:
          'If you get lost, call the host directly — they can guide you in real time.',
    ),
    (
      icon: '⏰',
      text: 'Allow extra travel time during peak hours (7–9 AM and 4–7 PM).',
    ),
    (
      icon: '🌙',
      text:
          'For late-night arrivals, contact the host in advance for gate access.',
    ),
  ];

  void _copyToClipboard(BuildContext context, ListingEntity listing) {
    final text =
        '📍 ${listing.title}\n📌 ${listing.location}, ${listing.city}\n\n'
        'Landmark directions:\n${listing.landmarkNote ?? "Contact host for directions."}\n\n'
        'GPS: ${listing.latitude}, ${listing.longitude}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Directions copied to clipboard')),
    );
  }
}

// ── Map Placeholder ────────────────────────────────────────────────────────

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.listing});

  final ListingEntity listing;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 220,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFB2DFDB), Color(0xFF80CBC4)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIcons.mapTrifold(),
                  size: 48,
                  color: Color(0xFF00897B),
                ),
                const SizedBox(height: 8),
                Text(
                  '${listing.city}, ${listing.country}',
                  style: AppTextStyles.labelLG.copyWith(
                    color: const Color(0xFF004D40),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Exact pin shared after booking',
                  style: AppTextStyles.bodyXS.copyWith(
                    color: const Color(0xFF00695C),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Location pin
        Positioned(
          top: 80,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(100),
                        blurRadius: 12,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Icon(
                    PhosphorIcons.house(),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Container(width: 2, height: 16, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Landmark Card ──────────────────────────────────────────────────────────

class _LandmarkCard extends StatelessWidget {
  const _LandmarkCard({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: const Color(0xFFFFCC02)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🗺️', style: TextStyle(fontSize: 24)),
          const SizedBox(width: AppDimensions.spaceLG),
          Expanded(
            child: Text(
              note,
              style: AppTextStyles.bodyMD.copyWith(height: 1.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Coordinate Row ─────────────────────────────────────────────────────────

class _CoordinateRow extends StatelessWidget {
  const _CoordinateRow({required this.lat, required this.lng});

  final double lat;
  final double lng;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Text(
            '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
            style: AppTextStyles.labelMD,
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: '$lat, $lng'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coordinates copied')),
              );
            },
            child: Icon(
              PhosphorIcons.copy(),
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tip Tile ───────────────────────────────────────────────────────────────

class _TipTile extends StatelessWidget {
  const _TipTile({required this.tip, required this.delay});

  final ({String icon, String text}) tip;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tip.icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: AppDimensions.spaceMD),
              Expanded(
                child: Text(
                  tip.text,
                  style: AppTextStyles.bodyMD.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.04, end: 0, duration: 350.ms);
  }
}
