import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:arenda/app/core/routes/app_routes.dart';
import 'package:arenda/app/core/theme/app_colors.dart';
import 'package:arenda/app/core/theme/app_dimensions.dart';
import 'package:arenda/app/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:arenda/app/features/search/application/search_notifier.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();

  static const _destinations = [
    _Destination(
      'Lagos',
      'Nigeria',
      'https://images.unsplash.com/photo-1580746738099-5f4e8c4f72c5?auto=format&fit=crop&w=600&q=80',
    ),
    _Destination(
      'Accra',
      'Ghana',
      'https://images.unsplash.com/photo-1582268611958-ebfd161ef9cf?auto=format&fit=crop&w=600&q=80',
    ),
    _Destination(
      'Abuja',
      'Nigeria',
      'https://images.unsplash.com/photo-1512917774899-7a3a02bab173?auto=format&fit=crop&w=600&q=80',
    ),
    _Destination(
      'Dakar',
      'Senegal',
      'https://images.unsplash.com/photo-1570129477492-45c003edd2be?auto=format&fit=crop&w=600&q=80',
    ),
    _Destination(
      'Nairobi',
      'Kenya',
      'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=600&q=80',
    ),
    _Destination(
      'Abidjan',
      'Côte d\'Ivoire',
      'https://images.unsplash.com/photo-1601597111158-2fceff292cdc?auto=format&fit=crop&w=600&q=80',
    ),
  ];

  static final _categories = [
    _Category('Appartements', PhosphorIcons.buildings()),
    _Category('Villas', PhosphorIcons.house(PhosphorIconsStyle.fill)),
    _Category('Shortlets', PhosphorIcons.bed()),
    _Category('Bord de mer', PhosphorIcons.umbrella()),
    _Category('Luxe', PhosphorIcons.star(PhosphorIconsStyle.fill)),
    _Category('Economique', PhosphorIcons.piggyBank()),
  ];

  void _goToResults(String query) {
    if (query.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    ref.read(searchProvider.notifier).search(query.trim());
    context.push(AppRoutes.searchResultsPath(query.trim()));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingPage,
                  AppDimensions.spaceXL,
                  AppDimensions.paddingPage,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                          'Ou sojourner ?',
                          style: AppTextStyles.displayMD.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 4),
                    Text(
                      'Trouvez votre logement ideal en Cote d Ivoire',
                      style: AppTextStyles.bodyMD.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ).animate(delay: 80.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: AppDimensions.spaceXL),

                    // ── Search bar ────────────────────────────────────────
                    _SearchBar(
                      controller: _ctrl,
                      focusNode: _focusNode,
                      onSubmitted: _goToResults,
                    ).animate(delay: 120.ms).fadeIn(duration: 400.ms),
                  ],
                ),
              ),
            ),

            // ── Popular destinations label ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingPage,
                  AppDimensions.spaceSM,
                  AppDimensions.paddingPage,
                  AppDimensions.spaceLG,
                ),
                child: Text('Villes populaires', style: AppTextStyles.h3),
              ).animate(delay: 180.ms).fadeIn(duration: 400.ms),
            ),

            // ── Destination cards ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingPage,
                  ),
                  itemCount: _destinations.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppDimensions.spaceMD),
                  itemBuilder: (_, i) =>
                      _DestinationCard(
                            destination: _destinations[i],
                            onTap: () => _goToResults(_destinations[i].city),
                          )
                          .animate(delay: (200 + i * 60).ms)
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: 0.2, end: 0),
                ),
              ),
            ),

            // ── Map preview banner ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingPage,
                  AppDimensions.spaceLG,
                  AppDimensions.paddingPage,
                  0,
                ),
                child: _MapPreviewBanner(
                  onTap: () => context.push(AppRoutes.mapSearch),
                ).animate(delay: 360.ms).fadeIn(duration: 400.ms),
              ),
            ),

            // ── Categories label ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingPage,
                  AppDimensions.spaceLG,
                  AppDimensions.paddingPage,
                  AppDimensions.spaceLG,
                ),
                child: Text('Explorer par type', style: AppTextStyles.h3),
              ).animate(delay: 420.ms).fadeIn(duration: 400.ms),
            ),

            // ── Category chips ────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingCard,
              ),
              sliver: SliverGrid.count(
                crossAxisCount: 3,
                mainAxisSpacing: AppDimensions.spaceSM,
                crossAxisSpacing: AppDimensions.spaceSM,
                childAspectRatio: 2.2,
                children: List.generate(
                  _categories.length,
                  (i) => _CategoryChip(
                    category: _categories[i],
                    onTap: () => _goToResults(_categories[i].label),
                  ).animate(delay: (420 + i * 50).ms).fadeIn(duration: 300.ms),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.space3XL),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search Bar ──────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        // border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        style: AppTextStyles.bodyMD,
        decoration: InputDecoration(
          hintText: 'Ville, quartier ou propriete...',
          hintStyle: AppTextStyles.bodyMD.copyWith(
            color: AppColors.textTertiary,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 10),
            child: Icon(
              PhosphorIcons.magnifyingGlass(),
              size: 22,
              color: AppColors.textSecondary,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(),
          suffixIcon: ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, val, _) => val.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      PhosphorIcons.x(),
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: controller.clear,
                  )
                : const SizedBox.shrink(),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

// ── Destination Card ────────────────────────────────────────────────────────

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({required this.destination, required this.onTap});
  final _Destination destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        child: SizedBox(
          width: 130,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              Image.network(
                destination.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.primarySurface,
                  child: Icon(
                    PhosphorIcons.buildings(),
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
              ),
              // Gradient overlay
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withAlpha(180)],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              // Text
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      destination.city,
                      style: AppTextStyles.labelMD.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      destination.country,
                      style: AppTextStyles.bodyXS.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Category Chip ───────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.onTap});
  final _Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category.icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              category.label,
              style: AppTextStyles.labelSM.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Map Preview Banner ──────────────────────────────────────────────────────

class _MapPreviewBanner extends StatelessWidget {
  const _MapPreviewBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(30),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Gradient background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F3460),
                      AppColors.primary,
                      Color(0xFF16213E),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              // Dot grid pattern overlay
              CustomPaint(painter: _DotGridPainter()),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(30),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'NOUVEAU',
                                  style: AppTextStyles.bodyXS.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 9,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Explorer sur la carte',
                            style: AppTextStyles.h3.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Trouvez des logements\nautour de vous',
                            style: AppTextStyles.bodyXS.copyWith(
                              color: Colors.white.withAlpha(200),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Map icon
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withAlpha(50),
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            PhosphorIcons.mapTrifold(PhosphorIconsStyle.fill),
                            size: 32,
                            color: Colors.white,
                          ),
                          Positioned(
                            right: 14,
                            top: 12,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow hint
              Positioned(
                right: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    PhosphorIcons.arrowUpRight(PhosphorIconsStyle.bold),
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(18)
      ..style = PaintingStyle.fill;
    const spacing = 18.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ── Data classes ────────────────────────────────────────────────────────────

class _Destination {
  const _Destination(this.city, this.country, this.imageUrl);
  final String city;
  final String country;
  final String imageUrl;
}

class _Category {
  const _Category(this.label, this.icon);
  final String label;
  final IconData icon;
}
