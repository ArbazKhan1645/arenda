import '../domain/entities/category_entity.dart';
import '../domain/entities/listing_entity.dart';

sealed class HomeState {
  const HomeState();
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.categories,
    required this.listings,
    required this.featuredListings,
    this.selectedCategoryId = 'all',
  });

  final List<CategoryEntity> categories;
  final List<ListingEntity> listings;
  final List<ListingEntity> featuredListings;
  final String selectedCategoryId;

  List<ListingEntity> get filteredListings {
    if (selectedCategoryId == 'all') return listings;
    return listings
        .where((l) => l.categoryId == selectedCategoryId)
        .toList();
  }

  HomeLoaded copyWith({
    List<CategoryEntity>? categories,
    List<ListingEntity>? listings,
    List<ListingEntity>? featuredListings,
    String? selectedCategoryId,
  }) {
    return HomeLoaded(
      categories: categories ?? this.categories,
      listings: listings ?? this.listings,
      featuredListings: featuredListings ?? this.featuredListings,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }
}

final class HomeError extends HomeState {
  const HomeError(this.message);
  final String message;
}
