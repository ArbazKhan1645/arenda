import 'package:arenda/app/features/booking/domain/entities/booking_entity.dart';
import 'package:arenda/app/features/home/domain/entities/listing_entity.dart';

sealed class BookingState {
  const BookingState();
}

final class BookingIdle extends BookingState {
  const BookingIdle();
}

final class BookingSelecting extends BookingState {
  const BookingSelecting({
    required this.listing,
    this.checkIn,
    this.checkOut,
    this.guests = 1,
  });

  final ListingEntity listing;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int guests;

  bool get canBook => checkIn != null && checkOut != null;
  int get nights => checkIn != null && checkOut != null
      ? checkOut!.difference(checkIn!).inDays
      : 0;
  double get subtotal => listing.discountedPrice * nights;
  double get total => subtotal + listing.cleaningFee + listing.serviceFee;

  BookingSelecting copyWith({
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
  }) => BookingSelecting(
    listing: listing,
    checkIn: checkIn ?? this.checkIn,
    checkOut: checkOut ?? this.checkOut,
    guests: guests ?? this.guests,
  );
}

final class BookingLoading extends BookingState {
  const BookingLoading();
}

final class BookingConfirmed extends BookingState {
  const BookingConfirmed(this.booking);
  final BookingEntity booking;
}

final class BookingError extends BookingState {
  const BookingError(this.message);
  final String message;
}
