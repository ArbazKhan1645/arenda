import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../application/search_notifier.dart';
import '../../application/search_state.dart';
import '../../../home/presentation/widgets/listing_card_widget.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: _SearchField(
          controller: _ctrl,
          focusNode: _focusNode,
          onChanged: (q) => ref.read(searchProvider.notifier).search(q),
          onClear: () {
            _ctrl.clear();
            ref.read(searchProvider.notifier).clear();
          },
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.tune_rounded),
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
      ),
      body: switch (searchState) {
        SearchIdle() => _RecentSearches(),
        SearchLoading() => _SearchLoadingView(),
        SearchLoaded(:final results, :final query) => results.isEmpty
            ? _EmptyResults(query: query)
            : _ResultsView(results: results),
        SearchError(:final message) => Center(child: Text(message)),
      },
    );
  }
}

// ── Search Field ───────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(right: AppDimensions.spaceSM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search destinations...',
          hintStyle:
              AppTextStyles.bodyMD.copyWith(color: AppColors.textTertiary),
          prefixIcon: const Icon(Icons.search_rounded,
              size: 18, color: AppColors.textSecondary),
          suffixIcon: ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, value, __) => value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 16, color: AppColors.textSecondary),
                    onPressed: onClear,
                  )
                : const SizedBox.shrink(),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

// ── Recent Searches ────────────────────────────────────────────────────────

class _RecentSearches extends StatelessWidget {
  final _suggestions = const [
    ('Bali, Indonesia', Icons.location_on_outlined),
    ('Paris, France', Icons.location_on_outlined),
    ('New York, USA', Icons.location_on_outlined),
    ('Tokyo, Japan', Icons.location_on_outlined),
    ('Santorini, Greece', Icons.location_on_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding:
          const EdgeInsets.symmetric(horizontal: AppDimensions.paddingPage),
      children: [
        const SizedBox(height: AppDimensions.spaceXL),
        Text('Popular destinations', style: AppTextStyles.h3),
        const SizedBox(height: AppDimensions.spaceLG),
        ..._suggestions.map(
          (s) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: Icon(s.$2, size: 20, color: AppColors.textSecondary),
            ),
            title: Text(s.$1, style: AppTextStyles.bodyMD),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

// ── Loading ────────────────────────────────────────────────────────────────

class _SearchLoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      itemCount: 3,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppDimensions.spaceXXL),
      itemBuilder: (_, __) => const ListingCardShimmer(),
    );
  }
}

// ── Results ────────────────────────────────────────────────────────────────

class _ResultsView extends StatelessWidget {
  const _ResultsView({required this.results});
  final List results;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      itemCount: results.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppDimensions.spaceXXL),
      itemBuilder: (_, i) => ListingCardWidget(
        listing: results[i],
        index: i,
      ),
    );
  }
}

// ── Empty ──────────────────────────────────────────────────────────────────

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 64, color: AppColors.border),
          const SizedBox(height: AppDimensions.spaceLG),
          Text('No results for "$query"', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            'Try a different location or adjust your filters',
            style:
                AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
