import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:arenda/app/features/home/domain/entities/listing_entity.dart';

part 'wishlist_notifier.g.dart';

@Riverpod(keepAlive: true)
class WishlistNotifier extends _$WishlistNotifier {
  @override
  List<ListingEntity> build() => [];

  void toggle(ListingEntity listing) {
    final exists = state.any((l) => l.id == listing.id);
    if (exists) {
      state = state.where((l) => l.id != listing.id).toList();
    } else {
      state = [...state, listing];
    }
  }

  bool isWishlisted(String listingId) => state.any((l) => l.id == listingId);
}
