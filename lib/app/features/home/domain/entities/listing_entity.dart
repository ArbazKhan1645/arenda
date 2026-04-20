// ── Media ──────────────────────────────────────────────────────────────────

enum ListingMediaType { image, video }

class ListingMediaItem {
  const ListingMediaItem({
    required this.url,
    required this.type,
    this.thumbnailUrl,
  });

  final String url;
  final ListingMediaType type;

  /// Explicit thumbnail for videos; falls back to url for images.
  final String? thumbnailUrl;

  bool get isVideo => type == ListingMediaType.video;

  String get effectiveThumbnail =>
      isVideo ? (thumbnailUrl ?? url) : url;
}

// ── Sub-models ─────────────────────────────────────────────────────────────

class ListingHost {
  const ListingHost({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.isSuperhost,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final bool isSuperhost;
}

class ListingLocation {
  const ListingLocation({
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.landmarkNote,
  });

  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;

  /// Plain-text landmark directions (West Africa-specific).
  final String? landmarkNote;
}

class ListingPrice {
  const ListingPrice({
    required this.perNight,
    this.cleaningFee = 0,
    this.serviceFee = 0,
    this.discountPercent = 0,
    this.tourismLevyPercent = 0,
    this.localCurrency = 'USD',
    this.localPerNight,
  });

  /// Base price in USD.
  final double perNight;
  final double cleaningFee;
  final double serviceFee;
  final int discountPercent;

  /// Tourism levy percentage (e.g. 5 = 5%).
  final double tourismLevyPercent;

  /// ISO 4217 code: GHS | NGN | XOF | USD | EUR …
  final String localCurrency;

  /// Price in local currency (null = use perNight in USD).
  final double? localPerNight;

  // ── Computed ───────────────────────────────────────────────────────────

  double get discountedPerNight => discountPercent > 0
      ? perNight * (1 - discountPercent / 100)
      : perNight;

  double get effective => localPerNight ?? perNight;

  String get currencySymbol {
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

  double levy(int nights) =>
      discountedPerNight * nights * (tourismLevyPercent / 100);

  double total(int nights) =>
      discountedPerNight * nights + cleaningFee + serviceFee + levy(nights);
}

class ListingSpecs {
  const ListingSpecs({
    required this.maxGuests,
    required this.bedrooms,
    required this.beds,
    required this.bathrooms,
    required this.propertyType,
    required this.amenities,
    this.powerType,
  });

  final int maxGuests;
  final int bedrooms;
  final int beds;
  final int bathrooms;

  /// Apartment | House | Villa | Shortlet | Studio | Duplex | Penthouse
  final String propertyType;

  final List<String> amenities;

  /// '24/7 Grid' | 'Solar Backup' | 'Generator Backup' | 'No Backup'
  final String? powerType;
}

// ── Main entity ────────────────────────────────────────────────────────────

class ListingEntity {
  const ListingEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.media,
    required this.host,
    required this.location,
    required this.price,
    required this.specs,
    required this.rating,
    required this.reviewCount,
    required this.categoryId,
    required this.isFeatured,
    required this.isNew,
    this.isPhysicallyVetted = false,
    this.verificationBadges = const [],
  });

  final String id;
  final String title;
  final String description;

  /// Ordered media: videos first, then images.
  final List<ListingMediaItem> media;

  final ListingHost host;
  final ListingLocation location;
  final ListingPrice price;
  final ListingSpecs specs;

  final double rating;
  final int reviewCount;
  final String categoryId;
  final bool isFeatured;
  final bool isNew;

  /// Host was physically visited and verified by platform staff.
  final bool isPhysicallyVetted;

  /// e.g. ['24/7 Power', 'Physically Vetted', 'High-Speed WiFi', 'CCTV']
  final List<String> verificationBadges;

  // ── Computed ─────────────────────────────────────────────────────────────

  String get thumbnailUrl =>
      media.isNotEmpty ? media.first.effectiveThumbnail : '';

  // ── Backward-compat getters (so existing screens compile unchanged) ───────

  String get hostId => host.id;
  String get hostName => host.name;
  String get hostAvatarUrl => host.avatarUrl;
  bool get hostIsSuperhost => host.isSuperhost;

  String get city => location.city;
  String get country => location.country;
  double get latitude => location.latitude;
  double get longitude => location.longitude;
  String? get landmarkNote => location.landmarkNote;

  double get pricePerNight => price.perNight;
  double get cleaningFee => price.cleaningFee;
  double get serviceFee => price.serviceFee;
  int get discountPercent => price.discountPercent;
  double get tourismLevyPercent => price.tourismLevyPercent;
  String get localCurrency => price.localCurrency;
  double? get localPricePerNight => price.localPerNight;
  double get discountedPrice => price.discountedPerNight;
  double get effectiveLocalPrice => price.effective;
  String get localCurrencySymbol => price.currencySymbol;
  double tourismLevy(int nights) => price.levy(nights);
  double totalForNights(int nights) => price.total(nights);

  int get maxGuests => specs.maxGuests;
  int get bedrooms => specs.bedrooms;
  int get beds => specs.beds;
  int get bathrooms => specs.bathrooms;
  String get propertyType => specs.propertyType;
  List<String> get amenities => specs.amenities;
  String? get powerType => specs.powerType;

  // ── copyWith ─────────────────────────────────────────────────────────────

  ListingEntity copyWith({
    String? id,
    String? title,
    String? description,
    List<ListingMediaItem>? media,
    ListingHost? host,
    ListingLocation? location,
    ListingPrice? price,
    ListingSpecs? specs,
    double? rating,
    int? reviewCount,
    String? categoryId,
    bool? isFeatured,
    bool? isNew,
    bool? isPhysicallyVetted,
    List<String>? verificationBadges,
  }) {
    return ListingEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      media: media ?? this.media,
      host: host ?? this.host,
      location: location ?? this.location,
      price: price ?? this.price,
      specs: specs ?? this.specs,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      categoryId: categoryId ?? this.categoryId,
      isFeatured: isFeatured ?? this.isFeatured,
      isNew: isNew ?? this.isNew,
      isPhysicallyVetted: isPhysicallyVetted ?? this.isPhysicallyVetted,
      verificationBadges: verificationBadges ?? this.verificationBadges,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ListingEntity && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
