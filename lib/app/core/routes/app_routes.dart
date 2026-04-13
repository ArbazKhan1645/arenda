abstract final class AppRoutes {
  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String splash      = '/';
  static const String onboarding  = '/onboarding';
  static const String login       = '/login';
  static const String signup      = '/signup';

  // ── Shell (Bottom Nav) ────────────────────────────────────────────────────
  static const String home        = '/home';
  static const String search      = '/search';
  static const String wishlist    = '/wishlist';
  static const String trips       = '/trips';
  static const String inbox       = '/inbox';
  static const String profile     = '/profile';

  // ── Listing ───────────────────────────────────────────────────────────────
  static const String listingDetail = '/listing/:id';
  static String listingDetailPath(String id) => '/listing/$id';

  // ── Search / Filters ──────────────────────────────────────────────────────
  static const String filters = '/filters';

  // ── Booking ───────────────────────────────────────────────────────────────
  static const String booking             = '/booking/:listingId';
  static String bookingPath(String id)    => '/booking/$id';
  static const String bookingConfirmation = '/booking-confirmation';

  // ── Payment ───────────────────────────────────────────────────────────────
  static const String payment = '/payment';

  // ── ID Verification ───────────────────────────────────────────────────────
  static const String idVerification = '/id-verification';

  // ── Profile sub-routes ────────────────────────────────────────────────────
  static const String editProfile    = '/edit-profile';
  static const String bookingHistory = '/booking-history';

  // ── Chat ──────────────────────────────────────────────────────────────────
  static const String conversation = '/conversation/:id';
  static String conversationPath(String id) => '/conversation/$id';

  // ── Reviews ───────────────────────────────────────────────────────────────
  static const String reviews    = '/reviews/:listingId';
  static String reviewsPath(String id)    => '/reviews/$id';
  static const String addReview  = '/add-review/:listingId';
  static String addReviewPath(String id)  => '/add-review/$id';

  // ── Landmark Navigation ───────────────────────────────────────────────────
  static const String landmark = '/landmark/:listingId';
  static String landmarkPath(String id) => '/landmark/$id';

  // ── Trust & Safety ────────────────────────────────────────────────────────
  static const String trustSafety = '/trust-safety';

  // ── Host ──────────────────────────────────────────────────────────────────
  static const String hostDashboard      = '/host/dashboard';
  static const String hostCreateListing  = '/host/create-listing';
  static const String payoutPreferences  = '/host/payout-preferences';
  static const String becomeHost         = '/host/become-host';
}
