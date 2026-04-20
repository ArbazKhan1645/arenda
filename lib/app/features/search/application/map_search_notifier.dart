import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../home/data/datasources/mock_home_datasource.dart';
import '../../home/domain/entities/listing_entity.dart';

part 'map_search_notifier.g.dart';

// ── Static demo user location (Abidjan, Plateau) ────────────────────────────
const LatLng kDemoUserLocation = LatLng(5.3364, -4.0267);

// ── State ────────────────────────────────────────────────────────────────────

sealed class MapSearchState {
  const MapSearchState();
}

final class MapSearchIdle extends MapSearchState {
  const MapSearchIdle();
}

final class MapSearchLoading extends MapSearchState {
  const MapSearchLoading();
}

final class MapSearchLoaded extends MapSearchState {
  const MapSearchLoaded({
    required this.allListings,
    required this.nearestListings,
    this.selectedId,
  });

  final List<ListingEntity> allListings;
  final List<NearestListing> nearestListings;
  final String? selectedId;

  MapSearchLoaded copyWith({
    List<ListingEntity>? allListings,
    List<NearestListing>? nearestListings,
    String? selectedId,
    bool clearSelected = false,
  }) =>
      MapSearchLoaded(
        allListings: allListings ?? this.allListings,
        nearestListings: nearestListings ?? this.nearestListings,
        selectedId: clearSelected ? null : (selectedId ?? this.selectedId),
      );
}

// ── Helper ───────────────────────────────────────────────────────────────────

class NearestListing {
  const NearestListing({required this.listing, required this.distanceKm});
  final ListingEntity listing;
  final double distanceKm;
}

// ── Notifier ─────────────────────────────────────────────────────────────────

@riverpod
class MapSearchNotifier extends _$MapSearchNotifier {
  @override
  MapSearchState build() => const MapSearchIdle();

  Future<void> load() async {
    state = const MapSearchLoading();
    await Future.delayed(const Duration(milliseconds: 600));

    final all = MockHomeDataSource.getListings();
    final nearest = _computeNearest(all);

    state = MapSearchLoaded(allListings: all, nearestListings: nearest);
  }

  void selectListing(String? id) {
    final current = state;
    if (current is MapSearchLoaded) {
      state = current.copyWith(selectedId: id, clearSelected: id == null);
    }
  }

  List<NearestListing> _computeNearest(List<ListingEntity> listings) {
    const distance = Distance();
    final result = listings.map((l) {
      final km = distance.as(
        LengthUnit.Kilometer,
        kDemoUserLocation,
        LatLng(l.latitude, l.longitude),
      );
      return NearestListing(listing: l, distanceKm: km);
    }).toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return result.take(6).toList();
  }
}
