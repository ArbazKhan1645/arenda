import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_rating_bar.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../home/domain/entities/review_entity.dart';
import '../../application/review_notifier.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ReviewsScreen extends ConsumerStatefulWidget {
  const ReviewsScreen({super.key, required this.listingId});

  final String listingId;

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(reviewProvider.notifier).load(widget.listingId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.plus()),
            tooltip: 'Write a review',
            onPressed: () =>
                context.push(AppRoutes.addReviewPath(widget.listingId)),
          ),
        ],
      ),
      body: switch (state) {
        ReviewLoading() => _LoadingView(),
        ReviewLoaded(:final reviews, :final averageRating) => _LoadedView(
          reviews: reviews,
          averageRating: averageRating,
          listingId: widget.listingId,
        ),
        ReviewError(:final message) => _ErrorView(
          message: message,
          onRetry: () =>
              ref.read(reviewProvider.notifier).load(widget.listingId),
        ),
      },
    );
  }
}

// ── Loading ────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      itemCount: 5,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppDimensions.spaceXXL),
      itemBuilder: (_, _) => const _ReviewTileShimmer(),
    );
  }
}

class _ReviewTileShimmer extends StatelessWidget {
  const _ReviewTileShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppShimmer(width: 44, height: 44, borderRadius: 22),
            const SizedBox(width: AppDimensions.spaceMD),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmer(width: 120, height: 14, borderRadius: 4),
                const SizedBox(height: 4),
                AppShimmer(width: 80, height: 12, borderRadius: 4),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        AppShimmer(width: double.infinity, height: 12, borderRadius: 4),
        const SizedBox(height: 6),
        AppShimmer(width: 200, height: 12, borderRadius: 4),
      ],
    );
  }
}

// ── Loaded ─────────────────────────────────────────────────────────────────

class _LoadedView extends StatelessWidget {
  const _LoadedView({
    required this.reviews,
    required this.averageRating,
    required this.listingId,
  });

  final List<ReviewEntity> reviews;
  final double averageRating;
  final String listingId;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return _EmptyView(listingId: listingId);
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _SummaryHeader(
            averageRating: averageRating,
            reviewCount: reviews.length,
            listingId: listingId,
          ).animate().fadeIn(duration: 400.ms),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingPage,
            AppDimensions.spaceXXL,
            AppDimensions.paddingPage,
            AppDimensions.space3XL,
          ),
          sliver: SliverList.separated(
            itemCount: reviews.length,
            separatorBuilder: (_, _) => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceXXL),
              child: Divider(),
            ),
            itemBuilder: (context, i) =>
                _ReviewTile(review: reviews[i], index: i),
          ),
        ),
      ],
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.averageRating,
    required this.reviewCount,
    required this.listingId,
  });

  final double averageRating;
  final int reviewCount;
  final String listingId;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingPage),
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
      ),
      child: Row(
        children: [
          // Big rating number
          Column(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: AppTextStyles.h1.copyWith(
                  fontSize: 56,
                  color: AppColors.primaryDark,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              AppRatingBar(
                rating: averageRating,
                size: 18,
                color: AppColors.primaryDark,
              ),
              const SizedBox(height: 4),
              Text(
                '$reviewCount ${reviewCount == 1 ? 'review' : 'reviews'}',
                style: AppTextStyles.bodySM.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppDimensions.spaceXXL),
          // Rating breakdown bars
          Expanded(child: _RatingBreakdown(averageRating: averageRating)),
        ],
      ),
    );
  }
}

class _RatingBreakdown extends StatelessWidget {
  const _RatingBreakdown({required this.averageRating});

  final double averageRating;

  @override
  Widget build(BuildContext context) {
    // Simulated breakdown based on average
    final bars = [5, 4, 3, 2, 1];
    final percents = _calculatePercents(averageRating);

    return Column(
      children: bars.asMap().entries.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Text(
                '${e.value}',
                style: AppTextStyles.bodyXS.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percents[e.key],
                    backgroundColor: AppColors.primary.withAlpha(40),
                    color: AppColors.primaryDark,
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<double> _calculatePercents(double avg) {
    // Distribute ratings based on average (approximation)
    final scores = [5, 4, 3, 2, 1];
    final weights = scores
        .map((s) => (1 - (avg - s).abs() / 4).clamp(0.0, 1.0))
        .toList();
    final total = weights.reduce((a, b) => a + b);
    return weights.map((w) => total > 0 ? w / total : 0.0).toList();
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review, required this.index});

  final ReviewEntity review;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppAvatar(
                  imageUrl: review.userAvatarUrl,
                  name: review.userName,
                  size: AppDimensions.avatarMD,
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.userName, style: AppTextStyles.labelMD),
                      const SizedBox(height: 2),
                      Text(
                        review.formattedDate,
                        style: AppTextStyles.bodyXS.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                AppRatingBar(rating: review.rating.toDouble(), size: 14),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            Text(
              review.comment,
              style: AppTextStyles.bodyMD.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.05, end: 0, duration: 400.ms);
  }
}

// ── Empty ──────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingPage),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIcons.star(PhosphorIconsStyle.fill),
              size: 72,
              color: AppColors.border,
            ),
            const SizedBox(height: AppDimensions.spaceLG),
            Text(
              'No reviews yet',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              'Be the first to share your experience!',
              style: AppTextStyles.bodyMD.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.space2XL),
            AppButton(
              label: 'Write a review',
              prefixIcon: Icon(
                PhosphorIcons.pencil(),
                size: 18,
                color: Colors.white,
              ),
              onPressed: () => context.push(AppRoutes.addReviewPath(listingId)),
            ),
          ],
        ).animate().fadeIn(duration: 500.ms),
      ),
    );
  }
}

// ── Error ──────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingPage),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            Text(message, style: AppTextStyles.bodyMD),
            const SizedBox(height: AppDimensions.spaceLG),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
