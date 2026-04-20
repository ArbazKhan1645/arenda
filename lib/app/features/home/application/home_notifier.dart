import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:arenda/app/features/home/data/datasources/mock_home_datasource.dart';
import 'package:arenda/app/features/home/application/home_state.dart';

part 'home_notifier.g.dart';

@Riverpod(keepAlive: true)
class HomeNotifier extends _$HomeNotifier {
  @override
  HomeState build() {
    _loadData();
    return const HomeInitial();
  }

  Future<void> _loadData() async {
    state = const HomeLoading();
    await Future.delayed(const Duration(milliseconds: 600));

    final categories = MockHomeDataSource.getCategories();
    final listings = MockHomeDataSource.getListings();
    final featured = listings.where((l) => l.isFeatured).toList();

    state = HomeLoaded(
      categories: categories,
      listings: listings,
      featuredListings: featured,
    );
  }

  void selectCategory(String categoryId) {
    final current = state;
    if (current is HomeLoaded) {
      state = current.copyWith(selectedCategoryId: categoryId);
    }
  }

  Future<void> refresh() => _loadData();
}
