import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:arenda/app/core/routes/app_routes.dart';
import 'package:arenda/app/core/theme/app_colors.dart';
import 'package:arenda/app/core/theme/app_text_styles.dart';
import 'package:arenda/app/core/theme/app_dimensions.dart';
import 'package:arenda/app/features/search/application/map_search_notifier.dart';
import 'package:arenda/app/features/home/domain/entities/listing_entity.dart';

class MapSearchScreen extends ConsumerStatefulWidget {
  const MapSearchScreen({super.key});

  @override
  ConsumerState<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends ConsumerState<MapSearchScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load data on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapSearchProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _flyTo(double lat, double lng) {
    _mapController.move(LatLng(lat, lng), 14);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapSearchProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // ── Custom AppBar ─────────────────────────────────────────────────
            _MapAppBar(tabController: _tabController),

            // ── Content ───────────────────────────────────────────────────────
            Expanded(
              child: switch (state) {
                MapSearchLoading() => _LoadingView(),
                MapSearchLoaded(
                  :final allListings,
                  :final nearestListings,
                  :final selectedId,
                ) =>
                  TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Tab 1: View on Map
                      _ViewOnMapTab(
                        listings: allListings,
                        selectedId: selectedId,
                        mapController: _mapController,
                        onMarkerTap: (l) {
                          ref
                              .read(mapSearchProvider.notifier)
                              .selectListing(l.id);
                          _flyTo(l.latitude, l.longitude);
                        },
                        onCardTap: (l) =>
                            context.push(AppRoutes.listingDetailPath(l.id)),
                      ),
                      // Tab 2: Nearest Me
                      _NearestMeTab(
                        listings: nearestListings,
                        onTap: (l) =>
                            context.push(AppRoutes.listingDetailPath(l.id)),
                      ),
                    ],
                  ),
                _ => _LoadingView(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom App Bar ────────────────────────────────────────────────────────────

class _MapAppBar extends StatelessWidget {
  const _MapAppBar({required this.tabController});
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Title row
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(PhosphorIcons.arrowLeft(), size: 22),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explorer la carte',
                          style: AppTextStyles.h3.copyWith(fontSize: 17),
                        ),
                        Text(
                          'Trouvez des logements sur la carte',
                          style: AppTextStyles.bodyXS.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                          size: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Abidjan',
                          style: AppTextStyles.labelSM.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tab bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: TabBar(
                controller: tabController,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMD - 2,
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTextStyles.labelMD.copyWith(fontSize: 13),
                unselectedLabelStyle: AppTextStyles.bodyMD.copyWith(
                  fontSize: 13,
                ),
                padding: const EdgeInsets.all(4),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(PhosphorIcons.mapPin(), size: 15),
                        const SizedBox(width: 6),
                        const Text('Voir sur la carte'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIcons.navigationArrow(
                            PhosphorIconsStyle.fill,
                          ),
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        const Text('Près de moi'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab 1: View on Map ────────────────────────────────────────────────────────

class _ViewOnMapTab extends StatelessWidget {
  const _ViewOnMapTab({
    required this.listings,
    required this.selectedId,
    required this.mapController,
    required this.onMarkerTap,
    required this.onCardTap,
  });

  final List<ListingEntity> listings;
  final String? selectedId;
  final MapController mapController;
  final ValueChanged<ListingEntity> onMarkerTap;
  final ValueChanged<ListingEntity> onCardTap;

  @override
  Widget build(BuildContext context) {
    final selected = selectedId != null
        ? listings.where((l) => l.id == selectedId).firstOrNull
        : null;

    return Stack(
      children: [
        // Map
        FlutterMap(
          mapController: mapController,
          options: const MapOptions(
            initialCenter: kDemoUserLocation,
            initialZoom: 5.0,
            minZoom: 3,
            maxZoom: 18,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://mt0.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}',
              userAgentPackageName: 'com.arenda.app',
            ),
            // User location marker
            MarkerLayer(
              markers: [
                Marker(
                  point: kDemoUserLocation,
                  width: 36,
                  height: 36,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withAlpha(70),
                          blurRadius: 12,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            // Listing markers
            MarkerLayer(
              markers: listings.map((l) {
                final isSelected = l.id == selectedId;
                return Marker(
                  point: LatLng(l.latitude, l.longitude),
                  width: isSelected ? 100 : 80,
                  height: isSelected ? 36 : 32,
                  child: GestureDetector(
                    onTap: () => onMarkerTap(l),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(isSelected ? 60 : 30),
                            blurRadius: isSelected ? 12 : 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '\$${l.pricePerNight.toInt()}',
                        style: AppTextStyles.labelSM.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // Bottom listing list
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected card popup
              if (selected != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child:
                      _SelectedListingCard(
                            listing: selected,
                            onTap: () => onCardTap(selected),
                          )
                          .animate()
                          .slideY(begin: 0.3, end: 0)
                          .fadeIn(duration: 200.ms),
                ),

              // Horizontal scrollable list
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(18),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${listings.length} logements',
                            style: AppTextStyles.labelSM.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 130,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: listings.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (_, i) =>
                            _MapListingTile(
                                  listing: listings[i],
                                  isSelected: listings[i].id == selectedId,
                                  onTap: () => onMarkerTap(listings[i]),
                                )
                                .animate(delay: (i * 40).ms)
                                .fadeIn(duration: 300.ms)
                                .slideX(begin: 0.2, end: 0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Tab 2: Nearest Me ─────────────────────────────────────────────────────────

class _NearestMeTab extends StatelessWidget {
  const _NearestMeTab({required this.listings, required this.onTap});
  final List<NearestListing> listings;
  final ValueChanged<ListingEntity> onTap;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withAlpha(20),
                        AppColors.primary.withAlpha(8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(color: AppColors.primary.withAlpha(40)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          PhosphorIcons.navigationArrow(
                            PhosphorIconsStyle.fill,
                          ),
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Votre position (démo)',
                              style: AppTextStyles.labelMD.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Le Plateau, Abidjan — Côte d\'Ivoire',
                              style: AppTextStyles.bodyXS.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        PhosphorIcons.check(PhosphorIconsStyle.fill),
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 20),
                Text(
                  'Logements les plus proches',
                  style: AppTextStyles.h3,
                ).animate(delay: 80.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: 4),
                Text(
                  'Triés par distance depuis votre position',
                  style: AppTextStyles.bodyXS.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          sliver: SliverList.separated(
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemCount: listings.length,
            itemBuilder: (_, i) =>
                _NearestListingRow(
                      item: listings[i],
                      rank: i + 1,
                      onTap: () => onTap(listings[i].listing),
                    )
                    .animate(delay: (120 + i * 60).ms)
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: 0.15, end: 0),
          ),
        ),
      ],
    );
  }
}

// ── Loading View ──────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Chargement de la carte...',
            style: AppTextStyles.bodyMD.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Selected Listing Popup Card ───────────────────────────────────────────────

class _SelectedListingCard extends StatelessWidget {
  const _SelectedListingCard({required this.listing, required this.onTap});
  final ListingEntity listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppDimensions.radiusLG),
              ),
              child: Image.network(
                listing.thumbnailUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 90,
                  color: AppColors.primarySurface,
                  child: Icon(
                    PhosphorIcons.house(PhosphorIconsStyle.fill),
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      listing.title,
                      style: AppTextStyles.labelMD,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${listing.city}, ${listing.country}',
                      style: AppTextStyles.bodyXS.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: Colors.amber.shade600,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          listing.rating.toStringAsFixed(2),
                          style: AppTextStyles.labelSM,
                        ),
                        const Spacer(),
                        Text(
                          '\$${listing.pricePerNight.toInt()}/nuit',
                          style: AppTextStyles.labelMD.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Map Listing Tile (horizontal scroll) ─────────────────────────────────────

class _MapListingTile extends StatelessWidget {
  const _MapListingTile({
    required this.listing,
    required this.isSelected,
    required this.onTap,
  });
  final ListingEntity listing;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppDimensions.radiusMD),
              ),
              child: Image.network(
                listing.thumbnailUrl,
                width: 70,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Container(width: 70, color: AppColors.primarySurface),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      listing.city,
                      style: AppTextStyles.labelSM.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      listing.title,
                      style: AppTextStyles.labelMD.copyWith(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      '\$${listing.pricePerNight.toInt()}/nuit',
                      style: AppTextStyles.labelSM.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Nearest Listing Row ───────────────────────────────────────────────────────

class _NearestListingRow extends StatelessWidget {
  const _NearestListingRow({
    required this.item,
    required this.rank,
    required this.onTap,
  });
  final NearestListing item;
  final int rank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = item.listing;
    final distStr = item.distanceKm < 1
        ? '${(item.distanceKm * 1000).toInt()} m'
        : '${item.distanceKm.toStringAsFixed(1)} km';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 44,
              decoration: BoxDecoration(
                color: rank == 1
                    ? AppColors.primary
                    : rank == 2
                    ? AppColors.primary.withAlpha(180)
                    : AppColors.primarySurface,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppDimensions.radiusLG),
                ),
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: AppTextStyles.h3.copyWith(
                    color: rank <= 2 ? Colors.white : AppColors.primary,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            // Image
            Image.network(
              l.thumbnailUrl,
              width: 90,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Container(width: 90, color: AppColors.primarySurface),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                          size: 11,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          distStr,
                          style: AppTextStyles.labelSM.copyWith(
                            color: AppColors.primary,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: Colors.amber.shade600,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          l.rating.toStringAsFixed(1),
                          style: AppTextStyles.labelSM.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.title,
                      style: AppTextStyles.labelMD.copyWith(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          l.city,
                          style: AppTextStyles.bodyXS.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\$${l.pricePerNight.toInt()}/nuit',
                          style: AppTextStyles.labelMD.copyWith(
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                PhosphorIcons.arrowRight(),
                size: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
