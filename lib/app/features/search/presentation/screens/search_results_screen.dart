import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:arenda/app/core/routes/app_routes.dart';
import 'package:arenda/app/core/theme/app_colors.dart';
import 'package:arenda/app/core/theme/app_dimensions.dart';
import 'package:arenda/app/core/theme/app_text_styles.dart';
import 'package:arenda/app/shared/widgets/app_shimmer.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:arenda/app/features/search/application/search_notifier.dart';
import 'package:arenda/app/features/search/application/search_state.dart';
import 'package:arenda/app/features/home/presentation/widgets/listing_card_widget.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key, required this.query});
  final String query;

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger search if not already searching this query
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = ref.read(searchProvider);
      final alreadyLoaded =
          current is SearchLoaded && current.query == widget.query;
      if (!alreadyLoaded) {
        ref.read(searchProvider.notifier).search(widget.query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft()),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.query,
              style: AppTextStyles.labelLG.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (searchState is SearchLoaded)
              Text(
                '${searchState.results.length} properties',
                style: AppTextStyles.bodyXS.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(PhosphorIcons.slidersHorizontal()),
                if (searchState is SearchLoaded && searchState.filters.isActive)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => context.push(AppRoutes.filters),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: switch (searchState) {
        SearchLoading() => _LoadingView(),
        SearchLoaded(:final results, :final query) =>
          results.isEmpty
              ? _EmptyView(query: query)
              : _ResultsView(results: results),
        SearchError(:final message) => _ErrorView(message: message),
        SearchIdle() => _LoadingView(),
      },
    );
  }
}

// ── Results list ─────────────────────────────────────────────────────────────

class _ResultsView extends StatelessWidget {
  const _ResultsView({required this.results});
  final List results;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingPage,
        AppDimensions.spaceLG,
        AppDimensions.paddingPage,
        AppDimensions.space3XL,
      ),
      itemCount: results.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppDimensions.spaceXXL),
      itemBuilder: (_, i) => ListingCardWidget(listing: results[i], index: i)
          .animate(delay: (i * 60).ms)
          .fadeIn(duration: 350.ms)
          .slideY(begin: 0.1, end: 0),
    );
  }
}

// ── Loading shimmer ───────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      itemCount: 4,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppDimensions.spaceXXL),
      itemBuilder: (_, _) => const ListingCardShimmer(),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingPage),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.magnifyingGlassMinus(),
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceLG),
            Text(
              'No results for "$query"',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              'Try a different location or adjust your filters',
              style: AppTextStyles.bodyMD.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: AppTextStyles.bodyMD.copyWith(color: AppColors.error),
      ),
    );
  }
}
