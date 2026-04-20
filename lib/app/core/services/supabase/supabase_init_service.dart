import 'package:arenda/app/core/enviroment_config_values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EXCEPTIONS
// ─────────────────────────────────────────────────────────────────────────────

class SupabaseInitException implements Exception {
  final String message;
  final Object? cause;
  const SupabaseInitException(this.message, {this.cause});

  @override
  String toString() =>
      'SupabaseInitException: $message${cause != null ? ' → $cause' : ''}';
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERFACE
// ─────────────────────────────────────────────────────────────────────────────

abstract class ISupabaseService {
  /// True once [initialize] has completed successfully
  bool get isInitialized;

  /// The raw [SupabaseClient] — use in repositories, never in UI
  SupabaseClient get client;

  /// Convenience: Supabase auth instance
  GoTrueClient get auth;

  /// Initialize Supabase — call once in main() before runApp()
  Future<void> initialize();
}

// ─────────────────────────────────────────────────────────────────────────────
// IMPLEMENTATION
// ─────────────────────────────────────────────────────────────────────────────

class SupabaseService implements ISupabaseService {
  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  SupabaseClient get client {
    assert(
      _initialized,
      '[SupabaseService] Not initialized yet. '
      'Call SupabaseService.initialize() in main() before accessing client.',
    );
    return Supabase.instance.client;
  }

  @override
  GoTrueClient get auth => client.auth;

  // ── INITIALIZE ──────────────────────────────────────────────────────────────

  @override
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('[SupabaseService] Already initialized — skipping');
      return;
    }

    try {
      // ── Credential validation (same pattern you provided) ─────────────────
      final url = KeysValuesConfig.supabaseUrl;
      final anonKey = KeysValuesConfig.supabaseAnonKey;

      assert(url.isNotEmpty, 'SUPABASE_URL is missing from .env file');
      assert(anonKey.isNotEmpty, 'SUPABASE_ANON_KEY is missing from .env file');

      // Runtime guard (assert only fires in debug — this fires in release too)
      if (url.isEmpty || anonKey.isEmpty) {
        throw const SupabaseInitException(
          'Supabase credentials are empty. '
          'Set SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define or .env.',
        );
      }

      // ── Supabase init ─────────────────────────────────────────────────────
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        debug: kDebugMode, // logs only in debug builds
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
        storageOptions: const StorageClientOptions(retryAttempts: 3),
      );

      _initialized = true;
      debugPrint('[SupabaseService] ✓ Initialized → $url');
    } on SupabaseInitException {
      rethrow;
    } catch (e) {
      throw SupabaseInitException('Failed to initialize Supabase', cause: e);
    }
  }
}

final supabaseServiceProvider = Provider<ISupabaseService>((ref) {
  throw UnimplementedError(
    'supabaseServiceProvider must be overridden in ProviderScope. '
    'Call SupabaseService().initialize() in main() and pass it as an override.',
  );
});

/// Direct access to [SupabaseClient] — use in repository providers
///
/// ```dart
/// final userRepo = Provider((ref) {
///   return UserRepository(client: ref.watch(supabaseClientProvider));
/// });
/// ```
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return ref.watch(supabaseServiceProvider).client;
});

/// Direct access to [GoTrueClient] — use in auth repository / notifiers
///
/// ```dart
/// final authRepo = Provider((ref) {
///   return AuthRepository(auth: ref.watch(supabaseAuthProvider));
/// });
/// ```
final supabaseAuthProvider = Provider<GoTrueClient>((ref) {
  return ref.watch(supabaseServiceProvider).auth;
});

/// Stream of [AuthState] changes — use in root widget or auth guard
///
/// ```dart
/// final authState = ref.watch(authStateStreamProvider);
/// authState.whenData((state) {
///   if (state.event == AuthChangeEvent.signedIn) { ... }
/// });
/// ```
final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseAuthProvider).onAuthStateChange;
});

/// Currently signed-in [User] — null when logged out
final currentUserProvider = Provider<User?>((ref) {
  // Re-evaluates whenever auth state changes
  ref.watch(authStateStreamProvider);
  return ref.watch(supabaseAuthProvider).currentUser;
});

/// True when a user session is active
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});
