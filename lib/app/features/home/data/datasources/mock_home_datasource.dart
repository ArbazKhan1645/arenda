import '../../domain/entities/category_entity.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/entities/review_entity.dart';

abstract final class MockHomeDataSource {
  static List<CategoryEntity> getCategories() => _categories;
  static List<ListingEntity> getListings() => _listings;
  static List<ReviewEntity> getReviews(String listingId) =>
      _reviews.where((r) => r.listingId == listingId).toList();
  static ListingEntity? getListingById(String id) {
    try {
      return _listings.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Categories ─────────────────────────────────────────────────────────────
  static final List<CategoryEntity> _categories = const [
    CategoryEntity(id: 'all', label: 'All', icon: '🌍'),
    CategoryEntity(id: 'shortlet', label: 'Shortlets', icon: '🏢'),
    CategoryEntity(id: 'apartment', label: 'Apartments', icon: '🏠'),
    CategoryEntity(id: 'villa', label: 'Villas', icon: '🏡'),
    CategoryEntity(id: 'duplex', label: 'Duplexes', icon: '🏘️'),
    CategoryEntity(id: 'studio', label: 'Studios', icon: '🛏️'),
    CategoryEntity(id: 'penthouse', label: 'Penthouses', icon: '💎'),
    CategoryEntity(id: 'beachfront', label: 'Beachfront', icon: '🏖️'),
    CategoryEntity(id: 'estate', label: 'Gated Estate', icon: '🔒'),
    CategoryEntity(id: 'luxury', label: 'Luxury', icon: '✨'),
    CategoryEntity(id: 'budget', label: 'Budget', icon: '🪙'),
    CategoryEntity(id: 'serviced', label: 'Serviced', icon: '🛎️'),
  ];

  // ── Listings ───────────────────────────────────────────────────────────────
  static final List<ListingEntity> _listings = [
    // ── ACCRA, GHANA ────────────────────────────────────────────────────────
    ListingEntity(
      id: 'l1',
      title: 'Luxury Penthouse in East Legon with Pool',
      description:
          'Experience Accra\'s finest living in this stunning 3-bedroom penthouse nestled within the prestigious East Legon residential area. Breathtaking city views stretch from every window, complemented by a rooftop infinity pool and a fully equipped gourmet kitchen.\n\nThe apartment is fitted with 24/7 backup power via solar and generator, fibre-optic internet (100Mbps), round-the-clock security, and a dedicated parking space. Perfect for business executives and discerning travellers.',
      media: const [
        // Video tour comes first
        ListingMediaItem(
          url:
              'https://paojjkvecolzqnoejexy.supabase.co/storage/v1/object/public/demo/12517889_3840_2160_25fps.mp4',
          type: ListingMediaType.video,
          thumbnailUrl:
              'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=900&q=80',
        ),
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
      ],
      host: const ListingHost(
        id: 'h1',
        name: 'Kwame Asante',
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
        isSuperhost: true,
      ),
      location: const ListingLocation(
        address: 'East Legon, Accra',
        city: 'Accra',
        country: 'Ghana',
        latitude: 5.6377,
        longitude: -0.1501,
        landmarkNote:
            'Located 5 minutes from Accra Mall, turn left at the Woodin fabric shop on the main East Legon road. The compound has a green gate with a "Horizon Residences" sign.',
      ),
      price: const ListingPrice(
        perNight: 120,
        cleaningFee: 30,
        serviceFee: 18,
        discountPercent: 0,
        localCurrency: 'GHS',
        localPerNight: 1800,
        tourismLevyPercent: 5,
      ),
      specs: const ListingSpecs(
        maxGuests: 6,
        bedrooms: 3,
        beds: 3,
        bathrooms: 3,
        propertyType: 'Penthouse',
        powerType: 'Solar Backup',
        amenities: [
          'wifi',
          'pool',
          'kitchen',
          'parking',
          'ac',
          'gym',
          'security',
          'generator',
        ],
      ),
      rating: 4.96,
      reviewCount: 88,
      categoryId: 'penthouse',
      isFeatured: true,
      isNew: false,
      isPhysicallyVetted: true,
      verificationBadges: [
        '24/7 Power',
        'Physically Vetted',
        'High-Speed WiFi',
        'CCTV',
      ],
    ),

    ListingEntity(
      id: 'l2',
      title: 'Modern Studio Shortlet in Cantonments',
      description:
          'A chic, fully furnished studio apartment in the heart of Cantonments — Accra\'s diplomatic quarter. The space features contemporary décor, premium finishes, and all the comforts needed for a short or extended stay.\n\nSwim in the communal pool, work from the high-speed fibre internet, and enjoy easy access to Osu Oxford Street restaurants and the Accra city centre.',
      media: const [
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1536376072261-38c75010e6c9?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
      ],
      host: const ListingHost(
        id: 'h2',
        name: 'Abena Osei',
        avatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
        isSuperhost: true,
      ),
      location: const ListingLocation(
        address: 'Cantonments, Accra',
        city: 'Accra',
        country: 'Ghana',
        latitude: 5.5754,
        longitude: -0.1888,
        landmarkNote:
            'On the Cantonments road opposite the American Embassy. Enter through the blue metal gate — ask the security guard for "Unit 4B". There\'s a yellow Melcom shop 100m before the entrance.',
      ),
      price: const ListingPrice(
        perNight: 65,
        cleaningFee: 15,
        serviceFee: 10,
        discountPercent: 10,
        localCurrency: 'GHS',
        localPerNight: 975,
        tourismLevyPercent: 5,
      ),
      specs: const ListingSpecs(
        maxGuests: 2,
        bedrooms: 1,
        beds: 1,
        bathrooms: 1,
        propertyType: 'Studio',
        powerType: 'Generator Backup',
        amenities: [
          'wifi',
          'pool',
          'kitchen',
          'ac',
          'parking',
          'washer',
          'security',
        ],
      ),
      rating: 4.89,
      reviewCount: 112,
      categoryId: 'studio',
      isFeatured: true,
      isNew: false,
      isPhysicallyVetted: true,
      verificationBadges: [
        '24/7 Power',
        'Physically Vetted',
        'High-Speed WiFi',
      ],
    ),

    ListingEntity(
      id: 'l3',
      title: 'Elegant 4-Bed Villa with Garden, Airport Ridge',
      description:
          'Stunning detached villa perfect for families and corporate groups. Set within a secure gated estate in Airport Ridge, this property offers the ideal blend of comfort, space, and privacy.\n\nThe villa comes with a landscaped garden with outdoor BBQ, spacious living and dining areas, fully equipped kitchen, and a dedicated housekeeper service. Airport Ridge is Accra\'s prime location — 10 minutes from Kotoka International Airport.',
      media: const [
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1582268611958-ebfd161ef9cf?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1568605114967-8130f3a36994?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
      ],
      host: const ListingHost(
        id: 'h3',
        name: 'Emmanuel Darko',
        avatarUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
        isSuperhost: false,
      ),
      location: const ListingLocation(
        address: 'Airport Ridge, Accra',
        city: 'Accra',
        country: 'Ghana',
        latitude: 5.6052,
        longitude: -0.1717,
        landmarkNote:
            'Inside Airport Ridge Estate, Gate B. Take the second turning after the Shell petrol station on the Liberation Road. Tell security at the main gate you are visiting "Villa 12 — Green Valley."',
      ),
      price: const ListingPrice(
        perNight: 195,
        cleaningFee: 55,
        serviceFee: 30,
        discountPercent: 0,
        localCurrency: 'GHS',
        localPerNight: 2925,
        tourismLevyPercent: 5,
      ),
      specs: const ListingSpecs(
        maxGuests: 8,
        bedrooms: 4,
        beds: 5,
        bathrooms: 4,
        propertyType: 'Villa',
        powerType: 'Generator Backup',
        amenities: [
          'wifi',
          'kitchen',
          'parking',
          'ac',
          'bbq',
          'garden',
          'security',
          'generator',
          'housekeeper',
        ],
      ),
      rating: 4.83,
      reviewCount: 45,
      categoryId: 'villa',
      isFeatured: true,
      isNew: false,
      isPhysicallyVetted: true,
      verificationBadges: [
        '24/7 Power',
        'Physically Vetted',
        'CCTV',
        'Gated Estate',
      ],
    ),

    // ── LAGOS, NIGERIA ───────────────────────────────────────────────────────
    ListingEntity(
      id: 'l4',
      title: 'Luxury Shortlet in Victoria Island with Ocean View',
      description:
          'Wake up to panoramic Atlantic Ocean views in this premium 2-bedroom shortlet apartment on Lagos\'s Victoria Island. Designed for executives and luxury travellers, the unit boasts Italian-tiled floors, bespoke furniture, and a floor-to-ceiling glass wall facing the ocean.\n\nLocated minutes from leading restaurants, the Lagos Marina, and key business districts. Your concierge will arrange airport transfers, grocery deliveries, and restaurant reservations.',
      media: const [
        // Video tour of the property
        ListingMediaItem(
          url:
              'https://paojjkvecolzqnoejexy.supabase.co/storage/v1/object/public/demo/6466244-uhd_2160_4096_25fps.mp4',
          type: ListingMediaType.video,
          thumbnailUrl:
              'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&w=900&q=80',
        ),
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1522708323590-d24dbb2b4358?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
      ],
      host: const ListingHost(
        id: 'h4',
        name: 'Chidi Okonkwo',
        avatarUrl:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=200&q=80',
        isSuperhost: true,
      ),
      location: const ListingLocation(
        address: 'Victoria Island, Lagos',
        city: 'Lagos',
        country: 'Nigeria',
        latitude: 6.4281,
        longitude: 3.4219,
        landmarkNote:
            'On Adeola Odeku Street, directly opposite GTBank VI branch. Look for the "Seaview Towers" signage — take the elevator to floor 14. Call the host upon arrival for seamless access.',
      ),
      price: const ListingPrice(
        perNight: 140,
        cleaningFee: 40,
        serviceFee: 22,
        discountPercent: 5,
        localCurrency: 'NGN',
        localPerNight: 224000,
        tourismLevyPercent: 7,
      ),
      specs: const ListingSpecs(
        maxGuests: 4,
        bedrooms: 2,
        beds: 2,
        bathrooms: 2,
        propertyType: 'Shortlet',
        powerType: 'Solar Backup',
        amenities: [
          'wifi',
          'kitchen',
          'ac',
          'parking',
          'gym',
          'pool',
          'security',
          'generator',
          'concierge',
        ],
      ),
      rating: 4.95,
      reviewCount: 73,
      categoryId: 'shortlet',
      isFeatured: true,
      isNew: false,
      isPhysicallyVetted: true,
      verificationBadges: [
        '24/7 Power',
        'Physically Vetted',
        'High-Speed WiFi',
        'CCTV',
        'Concierge',
      ],
    ),

    ListingEntity(
      id: 'l5',
      title: 'Cozy 1-Bedroom Flat in Lekki Phase 1',
      description:
          'Clean, secure, and stylishly furnished 1-bedroom apartment in the popular Lekki Phase 1 area. Ideal for solo travellers and couples who want a home-away-from-home experience without breaking the bank.\n\nFully air-conditioned, 24-hour security with CCTV, reliable generator backup, and fast WiFi. Walking distance to Lekki market, popular eateries, and easily accessible via BRT.',
      media: const [
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1536376072261-38c75010e6c9?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
      ],
      host: const ListingHost(
        id: 'h5',
        name: 'Funmi Adeyemi',
        avatarUrl:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=200&q=80',
        isSuperhost: false,
      ),
      location: const ListingLocation(
        address: 'Lekki Phase 1, Lagos',
        city: 'Lagos',
        country: 'Nigeria',
        latitude: 6.4468,
        longitude: 3.4739,
        landmarkNote:
            'Hakeem Dickson Street, off Admiralty Way. The building is painted cream and brown — look for "Sunrise Court" written above the entrance. It is 2 houses after the Access Bank ATM on that street.',
      ),
      price: const ListingPrice(
        perNight: 55,
        cleaningFee: 15,
        serviceFee: 8,
        discountPercent: 15,
        localCurrency: 'NGN',
        localPerNight: 88000,
        tourismLevyPercent: 7,
      ),
      specs: const ListingSpecs(
        maxGuests: 2,
        bedrooms: 1,
        beds: 1,
        bathrooms: 1,
        propertyType: 'Apartment',
        powerType: 'Generator Backup',
        amenities: [
          'wifi',
          'kitchen',
          'ac',
          'parking',
          'security',
          'generator',
          'washer',
        ],
      ),
      rating: 4.78,
      reviewCount: 91,
      categoryId: 'apartment',
      isFeatured: false,
      isNew: false,
      isPhysicallyVetted: true,
      verificationBadges: ['24/7 Power', 'Physically Vetted', 'CCTV'],
    ),

    ListingEntity(
      id: 'l6',
      title: 'Serviced Duplex in Ikoyi — Business Class Stay',
      description:
          'Premium 3-bedroom serviced duplex on the quiet and prestigious Ikoyi crescent. Designed specifically for long-stay business travellers and diplomatic guests, the property features dedicated office space, seamless 200Mbps fibre internet, and full hotel-grade housekeeping.\n\nPrepared breakfast is available on request. The host manages a portfolio of 12 verified properties and is available 24/7 via the app.',
      media: const [
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1570129477492-45c003edd2be?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1566073771259-470aff8a6e32?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
      ],
      host: const ListingHost(
        id: 'h6',
        name: 'Tolu Balogun',
        avatarUrl:
            'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=200&q=80',
        isSuperhost: true,
      ),
      location: const ListingLocation(
        address: 'Old Ikoyi, Lagos',
        city: 'Lagos',
        country: 'Nigeria',
        latitude: 6.4553,
        longitude: 3.4335,
        landmarkNote:
            'Joseph Street, Old Ikoyi. GPS is often inaccurate here — use this instead: from Awolowo Road, turn into Glover Road, take the second left after the Total petrol station. The duplex is the cream-coloured building with black iron gates, number 14.',
      ),
      price: const ListingPrice(
        perNight: 185,
        cleaningFee: 50,
        serviceFee: 28,
        discountPercent: 0,
        localCurrency: 'NGN',
        localPerNight: 296000,
        tourismLevyPercent: 7,
      ),
      specs: const ListingSpecs(
        maxGuests: 6,
        bedrooms: 3,
        beds: 3,
        bathrooms: 3,
        propertyType: 'Duplex',
        powerType: 'Solar Backup',
        amenities: [
          'wifi',
          'kitchen',
          'ac',
          'parking',
          'gym',
          'security',
          'generator',
          'housekeeper',
          'workspace',
          'breakfast',
        ],
      ),
      rating: 4.97,
      reviewCount: 58,
      categoryId: 'serviced',
      isFeatured: true,
      isNew: false,
      isPhysicallyVetted: true,
      verificationBadges: [
        '24/7 Power',
        'Physically Vetted',
        'High-Speed WiFi',
        'CCTV',
        'Gated Estate',
      ],
    ),

    // ── DAKAR, SENEGAL ───────────────────────────────────────────────────────
    ListingEntity(
      id: 'l7',
      title: 'Beachfront Retreat in Almadies, Dakar',
      description:
          'Spectacular 2-bedroom beachfront apartment with direct access to the Atlantic on the Almadies peninsula — Dakar\'s most coveted coastal address. Open-plan living flows out to a large private terrace where the ocean breeze is constant.\n\nIdeal for surfers, business travellers, and couples. Fast WiFi, solar power, and a highly-rated local catering service on request. French and Wolof-speaking staff available on-site.',
      media: const [
        // Video tour of the beachfront property
        ListingMediaItem(
          url:
              'https://paojjkvecolzqnoejexy.supabase.co/storage/v1/object/public/demo/14643006_1920_1080_100fps%20(1).mp4',
          type: ListingMediaType.video,
          thumbnailUrl:
              'https://images.unsplash.com/photo-1573843981267-be1999ff37cd?auto=format&fit=crop&w=900&q=80',
        ),
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1573843981267-be1999ff37cd?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1540202404-a2f29016b523?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
      ],
      host: const ListingHost(
        id: 'h7',
        name: 'Mariama Diallo',
        avatarUrl:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
        isSuperhost: true,
      ),
      location: const ListingLocation(
        address: 'Les Almadies, Dakar',
        city: 'Dakar',
        country: 'Senegal',
        latitude: 14.7456,
        longitude: -17.5102,
        landmarkNote:
            'Route de la Corniche-Ouest, Almadies. Coming from the Radisson Blu direction, pass the Club Med roundabout and continue 800m. Look for the orange building on the right, just before Plage des Almadies sign.',
      ),
      price: const ListingPrice(
        perNight: 85,
        cleaningFee: 25,
        serviceFee: 15,
        discountPercent: 0,
        localCurrency: 'XOF',
        localPerNight: 51000,
        tourismLevyPercent: 3,
      ),
      specs: const ListingSpecs(
        maxGuests: 4,
        bedrooms: 2,
        beds: 2,
        bathrooms: 2,
        propertyType: 'Apartment',
        powerType: 'Solar Backup',
        amenities: [
          'wifi',
          'kitchen',
          'ac',
          'beach_access',
          'parking',
          'security',
          'solar',
          'breakfast',
        ],
      ),
      rating: 4.92,
      reviewCount: 66,
      categoryId: 'beachfront',
      isFeatured: true,
      isNew: false,
      isPhysicallyVetted: true,
      verificationBadges: [
        '24/7 Power',
        'Physically Vetted',
        'High-Speed WiFi',
        'Beach Access',
      ],
    ),

    // ── ABIDJAN, IVORY COAST ─────────────────────────────────────────────────
    ListingEntity(
      id: 'l8',
      title: 'Executive Apartment in Plateau, Abidjan',
      description:
          'Prestigious fully-serviced 2-bedroom apartment in Le Plateau — the commercial and financial heart of Abidjan. Overlooking the Ébrié Lagoon, this high-floor unit offers exceptional views and world-class amenities.\n\nMinutes from the financial district, major embassies, and the Plateau business hub. Air France and corporate guests regularly choose this property for its proximity to the airport and reliability of service.',
      media: const [
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1501854140801-50d01698950b?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
        ListingMediaItem(
          url:
              'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=900&q=80',
          type: ListingMediaType.image,
        ),
      ],
      host: const ListingHost(
        id: 'h8',
        name: 'Kouamé Yao',
        avatarUrl:
            'https://images.unsplash.com/photo-1527980965255-d3b416303d12?auto=format&fit=crop&w=200&q=80',
        isSuperhost: false,
      ),
      location: const ListingLocation(
        address: 'Le Plateau, Abidjan',
        city: 'Abidjan',
        country: 'Ivory Coast',
        latitude: 5.3209,
        longitude: -4.0167,
        landmarkNote:
            'Avenue Botreau-Roussel, Le Plateau. Take the blue bridge from Cocody — the building is on your right after you pass SGBCI bank. It\'s a grey tower with "Résidence Lagune" in gold lettering.',
      ),
      price: const ListingPrice(
        perNight: 100,
        cleaningFee: 30,
        serviceFee: 18,
        discountPercent: 8,
        localCurrency: 'XOF',
        localPerNight: 60000,
        tourismLevyPercent: 4,
      ),
      specs: const ListingSpecs(
        maxGuests: 4,
        bedrooms: 2,
        beds: 2,
        bathrooms: 2,
        propertyType: 'Apartment',
        powerType: 'Generator Backup',
        amenities: [
          'wifi',
          'kitchen',
          'ac',
          'parking',
          'gym',
          'security',
          'generator',
          'concierge',
        ],
      ),
      rating: 4.85,
      reviewCount: 39,
      categoryId: 'serviced',
      isFeatured: true,
      isNew: true,
      isPhysicallyVetted: false,
      verificationBadges: ['High-Speed WiFi', 'CCTV', 'Gated Estate'],
    ),
  ];

  // ── Reviews ────────────────────────────────────────────────────────────────
  static final List<ReviewEntity> _reviews = [
    ReviewEntity(
      id: 'r1',
      listingId: 'l1',
      userId: 'u2',
      userName: 'Kofi Mensah',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
      rating: 5,
      comment:
          'Kwame\'s penthouse is absolutely stunning. The city views at night are breathtaking. Power never went out the entire week — solar + generator backup worked perfectly. Highly recommended for anyone visiting Accra!',
      createdAt: DateTime(2025, 2, 14),
    ),
    ReviewEntity(
      id: 'r2',
      listingId: 'l1',
      userId: 'u3',
      userName: 'Ama Boateng',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
      rating: 5,
      comment:
          'Perfect for our corporate retreat. The rooftop pool was an added bonus. Kwame was responsive and gave excellent local food recommendations. The landmark navigation note made it easy to find.',
      createdAt: DateTime(2025, 1, 28),
    ),
    ReviewEntity(
      id: 'r3',
      listingId: 'l1',
      userId: 'u4',
      userName: 'James Osei',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      rating: 4,
      comment:
          'Great location and amenities. The flat was clean and well-maintained. MTN MoMo payment was instant and hassle-free. Would deduct one star only because check-in was 30 mins late.',
      createdAt: DateTime(2024, 12, 10),
    ),
    ReviewEntity(
      id: 'r4',
      listingId: 'l2',
      userId: 'u5',
      userName: 'Yaw Darko',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=200&q=80',
      rating: 5,
      comment:
          'Abena\'s studio is the best shortlet I\'ve stayed in Accra. Clean, modern, and the location in Cantonments is perfect. Paid via Mobile Money — very smooth process.',
      createdAt: DateTime(2025, 3, 2),
    ),
    ReviewEntity(
      id: 'r5',
      listingId: 'l2',
      userId: 'u6',
      userName: 'Sophie Laurent',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
      rating: 5,
      comment:
          'As a French expat new to Accra, this was my first shortlet booking here. The landmark note was incredibly helpful — GPS kept pointing to the wrong building. Abena\'s instructions were spot-on.',
      createdAt: DateTime(2025, 2, 20),
    ),
    ReviewEntity(
      id: 'r6',
      listingId: 'l4',
      userId: 'u7',
      userName: 'Emeka Obi',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=200&q=80',
      rating: 5,
      comment:
          'Ocean views from VI don\'t get better than this. Chidi is an exceptional host — prompt, professional, and the concierge arranged everything. Paid via bank transfer, funds released smoothly after check-in.',
      createdAt: DateTime(2025, 1, 15),
    ),
    ReviewEntity(
      id: 'r7',
      listingId: 'l6',
      userId: 'u8',
      userName: 'Adesola Adewale',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=200&q=80',
      rating: 5,
      comment:
          'Stayed for 2 weeks for a corporate project. Tolu\'s duplex felt like a 5-star hotel. The dedicated workspace, fibre internet, and housekeeping made work-from-Ikoyi a joy. Will return.',
      createdAt: DateTime(2025, 3, 8),
    ),
    ReviewEntity(
      id: 'r8',
      listingId: 'l7',
      userId: 'u9',
      userName: 'Pierre Diagne',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1527980965255-d3b416303d12?auto=format&fit=crop&w=200&q=80',
      rating: 5,
      comment:
          'Mariama\'s apartment is a hidden gem in Almadies. Falling asleep to the sound of waves was pure magic. Solar power meant zero interruptions. The Wave payment worked seamlessly too!',
      createdAt: DateTime(2025, 2, 5),
    ),
  ];

  // ── Host mock data ─────────────────────────────────────────────────────────
  static List<ListingEntity> getHostListings(String hostId) =>
      _listings.where((l) => l.hostId == hostId).toList();
}
