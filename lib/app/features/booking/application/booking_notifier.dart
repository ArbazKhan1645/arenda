import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/booking_entity.dart';
import '../../home/domain/entities/listing_entity.dart';
import 'booking_state.dart';

part 'booking_notifier.g.dart';

@Riverpod(keepAlive: true)
class BookingNotifier extends _$BookingNotifier {
  final List<BookingEntity> _history = [];

  @override
  BookingState build() => const BookingIdle();

  void startBooking(ListingEntity listing) {
    state = BookingSelecting(listing: listing);
  }

  void setDates(DateTime checkIn, DateTime checkOut) {
    final current = state;
    if (current is BookingSelecting) {
      state = current.copyWith(checkIn: checkIn, checkOut: checkOut);
    }
  }

  void setGuests(int guests) {
    final current = state;
    if (current is BookingSelecting) {
      state = current.copyWith(guests: guests);
    }
  }

  Future<void> confirmBooking() async {
    final current = state;
    if (current is! BookingSelecting || !current.canBook) return;

    state = const BookingLoading();
    await Future.delayed(const Duration(milliseconds: 1200));

    final booking = BookingEntity(
      id: 'b${DateTime.now().millisecondsSinceEpoch}',
      listingId: current.listing.id,
      listingTitle: current.listing.title,
      listingThumbnail: current.listing.thumbnailUrl,
      listingCity: current.listing.city,
      userId: 'u1',
      checkIn: current.checkIn!,
      checkOut: current.checkOut!,
      guests: current.guests,
      pricePerNight: current.listing.discountedPrice,
      cleaningFee: current.listing.cleaningFee,
      serviceFee: current.listing.serviceFee,
      totalPrice: current.total,
      status: BookingStatus.confirmed,
      createdAt: DateTime.now(),
      hostName: current.listing.hostName,
      hostAvatarUrl: current.listing.hostAvatarUrl,
    );

    _history.add(booking);
    state = BookingConfirmed(booking);
  }

  void reset() => state = const BookingIdle();

  List<BookingEntity> get bookingHistory => List.unmodifiable(_history);
}
