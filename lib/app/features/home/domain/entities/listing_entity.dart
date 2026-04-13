class ListingEntity {
  const ListingEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.pricePerNight,
    required this.images,
    required this.hostId,
    required this.hostName,
    required this.hostAvatarUrl,
    required this.hostIsSuperhost,
    required this.rating,
    required this.reviewCount,
    required this.maxGuests,
    required this.bedrooms,
    required this.beds,
    required this.bathrooms,
    required this.amenities,
    required this.categoryId,
    required this.isFeatured,
    required this.isNew,
    this.discountPercent = 0,
    this.cleaningFee = 0,
    this.serviceFee = 0,
    // ── West Africa-specific ───────────────────────────────────────────
    this.verificationBadges = const [],
    this.landmarkNote,
    this.localCurrency = 'USD',
    this.localPricePerNight,
    this.isPhysicallyVetted = false,
    this.powerType,
    this.tourismLevyPercent = 0,
    this.propertyType = 'Apartment',
  });

  final String id;
  final String title;
  final String description;
  final String location;
  final String city;
  final String country;
  final double latitude;
  final double longitude;

  /// Price in USD
  final double pricePerNight;
  final List<String> images;
  final String hostId;
  final String hostName;
  final String hostAvatarUrl;
  final bool hostIsSuperhost;
  final double rating;
  final int reviewCount;
  final int maxGuests;
  final int bedrooms;
  final int beds;
  final int bathrooms;
  final List<String> amenities;
  final String categoryId;
  final bool isFeatured;
  final bool isNew;
  final int discountPercent;
  final double cleaningFee;
  final double serviceFee;

  // ── West Africa-specific ─────────────────────────────────────────────────
  /// e.g. ['24/7 Power', 'Physically Vetted', 'High-Speed WiFi', 'CCTV']
  final List<String> verificationBadges;

  /// Plain-text landmark directions e.g. "Opposite Total petrol station,
  /// 3 minutes walk from Accra Mall main gate"
  final String? landmarkNote;

  /// ISO 4217 currency code for local price display: GHS, NGN, XOF, USD
  final String localCurrency;

  /// Price in local currency (null = use pricePerNight in USD)
  final double? localPricePerNight;

  /// Host was physically visited and verified by platform staff
  final bool isPhysicallyVetted;

  /// '24/7 Grid' | 'Solar Backup' | 'Generator Backup' | 'No Backup'
  final String? powerType;

  /// Tourism levy percentage (e.g. 5 = 5%) — added to total at checkout
  final double tourismLevyPercent;

  /// Apartment | House | Villa | Shortlet | Studio | Duplex | Penthouse
  final String propertyType;

  // ── Computed ─────────────────────────────────────────────────────────────

  String get thumbnailUrl => images.isNotEmpty ? images.first : '';

  double get discountedPrice => discountPercent > 0
      ? pricePerNight * (1 - discountPercent / 100)
      : pricePerNight;

  double tourismLevy(int nights) =>
      discountedPrice * nights * (tourismLevyPercent / 100);

  double totalForNights(int nights) =>
      discountedPrice * nights +
      cleaningFee +
      serviceFee +
      tourismLevy(nights);

  double get effectiveLocalPrice =>
      localPricePerNight ?? pricePerNight;

  String get localCurrencySymbol {
    switch (localCurrency) {
      case 'GHS':
        return '₵';
      case 'NGN':
        return '₦';
      case 'XOF':
      case 'XAF':
        return 'CFA';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '\$';
    }
  }

  // ── copyWith ─────────────────────────────────────────────────────────────

  ListingEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    double? pricePerNight,
    List<String>? images,
    String? hostId,
    String? hostName,
    String? hostAvatarUrl,
    bool? hostIsSuperhost,
    double? rating,
    int? reviewCount,
    int? maxGuests,
    int? bedrooms,
    int? beds,
    int? bathrooms,
    List<String>? amenities,
    String? categoryId,
    bool? isFeatured,
    bool? isNew,
    int? discountPercent,
    double? cleaningFee,
    double? serviceFee,
    List<String>? verificationBadges,
    String? landmarkNote,
    String? localCurrency,
    double? localPricePerNight,
    bool? isPhysicallyVetted,
    String? powerType,
    double? tourismLevyPercent,
    String? propertyType,
  }) {
    return ListingEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      images: images ?? this.images,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      hostAvatarUrl: hostAvatarUrl ?? this.hostAvatarUrl,
      hostIsSuperhost: hostIsSuperhost ?? this.hostIsSuperhost,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      maxGuests: maxGuests ?? this.maxGuests,
      bedrooms: bedrooms ?? this.bedrooms,
      beds: beds ?? this.beds,
      bathrooms: bathrooms ?? this.bathrooms,
      amenities: amenities ?? this.amenities,
      categoryId: categoryId ?? this.categoryId,
      isFeatured: isFeatured ?? this.isFeatured,
      isNew: isNew ?? this.isNew,
      discountPercent: discountPercent ?? this.discountPercent,
      cleaningFee: cleaningFee ?? this.cleaningFee,
      serviceFee: serviceFee ?? this.serviceFee,
      verificationBadges: verificationBadges ?? this.verificationBadges,
      landmarkNote: landmarkNote ?? this.landmarkNote,
      localCurrency: localCurrency ?? this.localCurrency,
      localPricePerNight: localPricePerNight ?? this.localPricePerNight,
      isPhysicallyVetted: isPhysicallyVetted ?? this.isPhysicallyVetted,
      powerType: powerType ?? this.powerType,
      tourismLevyPercent: tourismLevyPercent ?? this.tourismLevyPercent,
      propertyType: propertyType ?? this.propertyType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ListingEntity && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
