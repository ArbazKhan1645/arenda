import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:arenda/app/features/home/data/datasources/mock_home_datasource.dart';
import 'package:arenda/app/features/home/domain/entities/review_entity.dart';

part 'review_notifier.g.dart';

sealed class ReviewState {
  const ReviewState();
}

final class ReviewLoading extends ReviewState {
  const ReviewLoading();
}

final class ReviewLoaded extends ReviewState {
  const ReviewLoaded(this.reviews);
  final List<ReviewEntity> reviews;

  double get averageRating {
    if (reviews.isEmpty) return 0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) /
        reviews.length;
  }
}

final class ReviewError extends ReviewState {
  const ReviewError(this.message);
  final String message;
}

@Riverpod()
class ReviewNotifier extends _$ReviewNotifier {
  @override
  ReviewState build() => const ReviewLoading();

  Future<void> load(String listingId) async {
    state = const ReviewLoading();
    await Future.delayed(const Duration(milliseconds: 400));
    final reviews = MockHomeDataSource.getReviews(listingId);
    state = ReviewLoaded(reviews);
  }

  Future<void> addReview({
    required String listingId,
    required int rating,
    required String comment,
  }) async {
    final current = state;
    if (current is! ReviewLoaded) return;

    final newReview = ReviewEntity(
      id: 'r${DateTime.now().millisecondsSinceEpoch}',
      listingId: listingId,
      userId: 'u1',
      userName: 'Alex Johnson',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    state = ReviewLoaded([newReview, ...current.reviews]);
  }
}
