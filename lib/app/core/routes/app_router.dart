import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arenda/app/features/authentication/presentation/screens/onboarding_screen.dart';
import 'package:arenda/app/features/authentication/presentation/screens/login_screen.dart';
import 'package:arenda/app/features/authentication/presentation/screens/signup_screen.dart';
import 'package:arenda/app/features/authentication/presentation/screens/otp_screen.dart';
import 'package:arenda/app/features/authentication/presentation/screens/reset_password_screen.dart';
import 'package:arenda/app/features/home/presentation/screens/home_screen.dart';
import 'package:arenda/app/features/home/presentation/screens/main_shell.dart';
import 'package:arenda/app/features/search/presentation/screens/search_screen.dart';
import 'package:arenda/app/features/search/presentation/screens/search_results_screen.dart';
import 'package:arenda/app/features/search/presentation/screens/filters_screen.dart';
import 'package:arenda/app/features/search/presentation/screens/map_search_screen.dart';
import 'package:arenda/app/features/listing/presentation/screens/listing_detail_screen.dart';
import 'package:arenda/app/features/listing/presentation/screens/landmark_navigation_screen.dart';
import 'package:arenda/app/features/booking/presentation/screens/booking_screen.dart';
import 'package:arenda/app/features/booking/presentation/screens/booking_confirmation_screen.dart';
import 'package:arenda/app/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:arenda/app/features/profile/presentation/screens/profile_screen.dart';
import 'package:arenda/app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:arenda/app/features/profile/presentation/screens/booking_history_screen.dart';
import 'package:arenda/app/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:arenda/app/features/chat/presentation/screens/conversation_screen.dart';
import 'package:arenda/app/features/reviews/presentation/screens/reviews_screen.dart';
import 'package:arenda/app/features/reviews/presentation/screens/add_review_screen.dart';
import 'package:arenda/app/features/payment/presentation/screens/payment_screen.dart';
import 'package:arenda/app/features/payment/presentation/screens/id_verification_screen.dart';
import 'package:arenda/app/features/trust/presentation/screens/trust_safety_screen.dart';
import 'package:arenda/app/features/host/presentation/screens/host_dashboard_screen.dart';
import 'package:arenda/app/features/host/presentation/screens/host_create_listing_screen.dart';
import 'package:arenda/app/features/host/presentation/screens/payout_preferences_screen.dart';
import 'package:arenda/app/features/host/presentation/screens/become_host_screen.dart';
import 'package:arenda/app/core/routes/app_routes.dart';
part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final initialRouteProvider = Provider<String>(
  (ref) => throw UnimplementedError(),
);

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final initialLocation = ref.read(initialRouteProvider);
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      // ── Auth ───────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) =>
            _slideFromBottom(state, const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) =>
            _slideFromBottom(state, const SignupScreen()),
      ),
      GoRoute(
        path: AppRoutes.otp,
        pageBuilder: (context, state) {
          final args = state.extra as OtpArgs;
          return _slideFromBottom(state, OtpScreen(args: args));
        },
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        pageBuilder: (context, state) =>
            _slideFromBottom(state, const ResetPasswordScreen()),
      ),

      // ── Shell ──────────────────────────────────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.search,
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: AppRoutes.wishlist,
            builder: (context, state) => const WishlistScreen(),
          ),
          GoRoute(
            path: AppRoutes.trips,
            builder: (context, state) => const BookingHistoryScreen(),
          ),
          GoRoute(
            path: AppRoutes.inbox,
            builder: (context, state) => const ChatListScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // ── Listing Detail ─────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.listingDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _slideFromRight(state, ListingDetailScreen(listingId: id));
        },
      ),

      // ── Landmark Navigation ────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.landmark,
        pageBuilder: (context, state) {
          final id = state.pathParameters['listingId']!;
          return _slideFromRight(
            state,
            LandmarkNavigationScreen(listingId: id),
          );
        },
      ),

      // ── Search Results ─────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.searchResults,
        pageBuilder: (context, state) {
          final query = state.pathParameters['query']!;
          return _slideFromRight(state, SearchResultsScreen(query: query));
        },
      ),

      // ── Search Filters ─────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.filters,
        pageBuilder: (context, state) =>
            _slideFromBottom(state, const FiltersScreen()),
      ),

      // ── Map Search ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.mapSearch,
        pageBuilder: (context, state) =>
            _slideFromBottom(state, const MapSearchScreen()),
      ),

      // ── Booking ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.booking,
        pageBuilder: (context, state) {
          final listingId = state.pathParameters['listingId']!;
          return _slideFromBottom(state, BookingScreen(listingId: listingId));
        },
      ),
      GoRoute(
        path: AppRoutes.bookingConfirmation,
        pageBuilder: (context, state) =>
            _slideFromBottom(state, const BookingConfirmationScreen()),
      ),

      // ── Payment ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.payment,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return _slideFromBottom(
            state,
            PaymentScreen(
              listingTitle: extra['listingTitle'] as String? ?? 'Booking',
              totalUSD: (extra['totalUSD'] as num?)?.toDouble() ?? 0,
              nights: (extra['nights'] as int?) ?? 1,
              localCurrency: extra['localCurrency'] as String? ?? 'USD',
              localTotal: (extra['localTotal'] as num?)?.toDouble() ?? 0,
            ),
          );
        },
      ),

      // ── ID Verification ────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.idVerification,
        pageBuilder: (context, state) {
          final returnRoute = state.extra as String?;
          return _slideFromRight(
            state,
            IdVerificationScreen(returnRoute: returnRoute),
          );
        },
      ),

      // ── Profile sub-routes ─────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.editProfile,
        pageBuilder: (context, state) =>
            _slideFromRight(state, const EditProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.bookingHistory,
        pageBuilder: (context, state) =>
            _slideFromRight(state, const BookingHistoryScreen()),
      ),

      // ── Chat ───────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.conversation,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _slideFromRight(state, ConversationScreen(conversationId: id));
        },
      ),

      // ── Reviews ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.reviews,
        pageBuilder: (context, state) {
          final id = state.pathParameters['listingId']!;
          return _slideFromRight(state, ReviewsScreen(listingId: id));
        },
      ),
      GoRoute(
        path: AppRoutes.addReview,
        pageBuilder: (context, state) {
          final id = state.pathParameters['listingId']!;
          return _slideFromBottom(state, AddReviewScreen(listingId: id));
        },
      ),

      // ── Trust & Safety ─────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.trustSafety,
        pageBuilder: (context, state) =>
            _slideFromRight(state, const TrustSafetyScreen()),
      ),

      // ── Host ───────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.hostDashboard,
        pageBuilder: (context, state) =>
            _slideFromRight(state, const HostDashboardScreen()),
      ),
      GoRoute(
        path: AppRoutes.hostCreateListing,
        pageBuilder: (context, state) =>
            _slideFromRight(state, const HostCreateListingScreen()),
      ),
      GoRoute(
        path: AppRoutes.payoutPreferences,
        pageBuilder: (context, state) =>
            _slideFromRight(state, const PayoutPreferencesScreen()),
      ),
      GoRoute(
        path: AppRoutes.becomeHost,
        pageBuilder: (context, state) =>
            _slideFromBottom(state, const BecomeHostScreen()),
      ),
    ],
  );
}

CustomTransitionPage<void> _slideFromRight(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: child,
      );
    },
  );
}

CustomTransitionPage<void> _slideFromBottom(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: child,
      );
    },
  );
}
