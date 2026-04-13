import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../home/data/datasources/mock_home_datasource.dart';
import 'search_state.dart';

part 'search_notifier.g.dart';

@Riverpod(keepAlive: true)
class SearchNotifier extends _$SearchNotifier {
  @override
  SearchState build() => const SearchIdle();

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const SearchIdle();
      return;
    }

    state = const SearchLoading();
    await Future.delayed(const Duration(milliseconds: 400));

    final all = MockHomeDataSource.getListings();
    final q = query.toLowerCase().trim();

    final results = all.where((l) {
      return l.title.toLowerCase().contains(q) ||
          l.city.toLowerCase().contains(q) ||
          l.country.toLowerCase().contains(q) ||
          l.location.toLowerCase().contains(q);
    }).toList();

    final current = state;
    final filters =
        current is SearchLoaded ? current.filters : const SearchFilters();

    state = SearchLoaded(results: results, query: query, filters: filters);
  }

  void applyFilters(SearchFilters filters) {
    final current = state;
    if (current is SearchLoaded) {
      final all = MockHomeDataSource.getListings();
      final q = current.query.toLowerCase().trim();

      var results = all.where((l) {
        return l.title.toLowerCase().contains(q) ||
            l.city.toLowerCase().contains(q) ||
            l.country.toLowerCase().contains(q);
      }).toList();

      results = results.where((l) {
        if (l.pricePerNight < filters.minPrice) return false;
        if (l.pricePerNight > filters.maxPrice) return false;
        if (l.bedrooms < filters.minBedrooms) return false;
        if (l.bathrooms < filters.minBathrooms) return false;
        if (l.maxGuests < filters.minGuests) return false;
        if (filters.superhost && !l.hostIsSuperhost) return false;
        return true;
      }).toList();

      state = current.copyWith(results: results, filters: filters);
    }
  }

  void setDates(DateTime? checkIn, DateTime? checkOut) {
    final current = state;
    if (current is SearchLoaded) {
      state = current.copyWith(checkIn: checkIn, checkOut: checkOut);
    }
  }

  void setGuests(int guests) {
    final current = state;
    if (current is SearchLoaded) {
      state = current.copyWith(guests: guests);
    }
  }

  void clear() => state = const SearchIdle();
}
