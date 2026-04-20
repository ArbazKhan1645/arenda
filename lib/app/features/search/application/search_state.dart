import 'package:arenda/app/features/home/domain/entities/listing_entity.dart';

class SearchFilters {
  const SearchFilters({
    this.minPrice = 0,
    this.maxPrice = 1000,
    this.minBedrooms = 0,
    this.minBathrooms = 0,
    this.minGuests = 1,
    this.selectedAmenities = const [],
    this.instantBook = false,
    this.superhost = false,
  });

  final double minPrice;
  final double maxPrice;
  final int minBedrooms;
  final int minBathrooms;
  final int minGuests;
  final List<String> selectedAmenities;
  final bool instantBook;
  final bool superhost;

  bool get isActive =>
      minPrice > 0 ||
      maxPrice < 1000 ||
      minBedrooms > 0 ||
      minBathrooms > 0 ||
      minGuests > 1 ||
      selectedAmenities.isNotEmpty ||
      instantBook ||
      superhost;

  SearchFilters copyWith({
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    int? minBathrooms,
    int? minGuests,
    List<String>? selectedAmenities,
    bool? instantBook,
    bool? superhost,
  }) => SearchFilters(
    minPrice: minPrice ?? this.minPrice,
    maxPrice: maxPrice ?? this.maxPrice,
    minBedrooms: minBedrooms ?? this.minBedrooms,
    minBathrooms: minBathrooms ?? this.minBathrooms,
    minGuests: minGuests ?? this.minGuests,
    selectedAmenities: selectedAmenities ?? this.selectedAmenities,
    instantBook: instantBook ?? this.instantBook,
    superhost: superhost ?? this.superhost,
  );
}

sealed class SearchState {
  const SearchState();
}

final class SearchIdle extends SearchState {
  const SearchIdle();
}

final class SearchLoading extends SearchState {
  const SearchLoading();
}

final class SearchLoaded extends SearchState {
  const SearchLoaded({
    required this.results,
    required this.query,
    required this.filters,
    this.checkIn,
    this.checkOut,
    this.guests = 1,
  });

  final List<ListingEntity> results;
  final String query;
  final SearchFilters filters;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int guests;

  SearchLoaded copyWith({
    List<ListingEntity>? results,
    String? query,
    SearchFilters? filters,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
  }) => SearchLoaded(
    results: results ?? this.results,
    query: query ?? this.query,
    filters: filters ?? this.filters,
    checkIn: checkIn ?? this.checkIn,
    checkOut: checkOut ?? this.checkOut,
    guests: guests ?? this.guests,
  );
}

final class SearchError extends SearchState {
  const SearchError(this.message);
  final String message;
}
