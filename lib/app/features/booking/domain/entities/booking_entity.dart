enum BookingStatus { pending, confirmed, cancelled, completed }

class BookingEntity {
  const BookingEntity({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.listingThumbnail,
    required this.listingCity,
    required this.userId,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.pricePerNight,
    required this.cleaningFee,
    required this.serviceFee,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.hostName,
    this.hostAvatarUrl,
  });

  final String id;
  final String listingId;
  final String listingTitle;
  final String listingThumbnail;
  final String listingCity;
  final String userId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final double pricePerNight;
  final double cleaningFee;
  final double serviceFee;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;
  final String? hostName;
  final String? hostAvatarUrl;

  int get nights => checkOut.difference(checkIn).inDays;

  String get statusLabel => switch (status) {
        BookingStatus.pending => 'Pending',
        BookingStatus.confirmed => 'Confirmed',
        BookingStatus.cancelled => 'Cancelled',
        BookingStatus.completed => 'Completed',
      };

  String get formattedDates {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final checkInStr =
        '${months[checkIn.month - 1]} ${checkIn.day}';
    final checkOutStr =
        '${months[checkOut.month - 1]} ${checkOut.day}, ${checkOut.year}';
    return '$checkInStr – $checkOutStr';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is BookingEntity && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
