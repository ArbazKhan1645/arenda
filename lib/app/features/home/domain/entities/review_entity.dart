class ReviewEntity {
  const ReviewEntity({
    required this.id,
    required this.listingId,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String listingId;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final int rating;
  final String comment;
  final DateTime createdAt;

  String get formattedDate {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[createdAt.month - 1]} ${createdAt.year}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ReviewEntity && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
