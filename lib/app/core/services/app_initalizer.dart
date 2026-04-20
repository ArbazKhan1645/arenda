import 'package:arenda/app/core/routes/app_routes.dart';
import 'package:arenda/app/core/services/local/cache_service.dart';
import 'package:arenda/app/features/authentication/data/datasources/mock_auth_datasource.dart';

import 'package:arenda/app/core/services/local/storage_service.dart';
import 'package:arenda/app/core/services/supabase/supabase_init_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RESULT — carries all initialized services into ProviderScope overrides
// ─────────────────────────────────────────────────────────────────────────────

class AppInitResult {
  final StorageService storageService;
  final SupabaseService supabaseService;
  final CacheService cacheService;
  final String initialRoute;

  const AppInitResult({
    required this.storageService,
    required this.supabaseService,
    required this.cacheService,
    required this.initialRoute,
  });

  /// Converts initialized services into Riverpod ProviderScope overrides
  List<Override> get providerOverrides => [
    supabaseServiceProvider.overrideWithValue(supabaseService),
    storageServiceProvider.overrideWithValue(storageService),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// APP INITIALIZER
// ─────────────────────────────────────────────────────────────────────────────

class AppInitializer {
  const AppInitializer._();

  static Future<AppInitResult> initialize() async {
    // ── 1. Load .env ──────────────────────────────────────────────────────────
    await _loadEnv();

    // ── 2. Lock orientation ───────────────────────────────────────────────────
    await _lockOrientation();

    // ── 3. Storage ────────────────────────────────────────────────────────────
    final storageService = await _initStorage();

    // ── 4. Supabase ───────────────────────────────────────────────────────────
    final supabaseService = await _initSupabase();

    // ── 5. Cache (synchronous init, no await needed) ──────────────────────────
    final cacheService = _initCache();

    // ── 6. Determine Initial Route ────────────────────────────────────────────
    final currentUser = await MockAuthDataSource.getCurrentUser();
    final hasSeenOnboarding = await MockAuthDataSource.isOnboarded();
    final initialRoute = currentUser != null
        ? AppRoutes.home
        : (hasSeenOnboarding ? AppRoutes.login : AppRoutes.onboarding);

    debugPrint('[AppInitializer] ✓ All services initialized');

    return AppInitResult(
      storageService: storageService,
      supabaseService: supabaseService,
      cacheService: cacheService,
      initialRoute: initialRoute,
    );
  }

  // ── STEPS ───────────────────────────────────────────────────────────────────

  static Future<void> _loadEnv() async {
    try {
      await dotenv.load(fileName: '.env');
      debugPrint('[AppInitializer] ✓ .env loaded');
    } catch (_) {
      // .env missing is acceptable in CI / release builds using --dart-define
      debugPrint(
        '[AppInitializer] ⚠ .env not found — using --dart-define values',
      );
    }
  }

  static Future<void> _lockOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    debugPrint('[AppInitializer] ✓ Orientation locked to portrait');
  }

  static Future<StorageService> _initStorage() async {
    try {
      final service = await StorageService.init();
      debugPrint('[AppInitializer] ✓ StorageService ready');
      return service;
    } catch (e) {
      // Storage failure is fatal — app cannot function without it
      throw AppInitException('StorageService failed to initialize', cause: e);
    }
  }

  static Future<SupabaseService> _initSupabase() async {
    try {
      final service = SupabaseService();
      // await service.initialize();
      debugPrint('[AppInitializer] ✓ SupabaseService ready');
      return service;
    } on SupabaseInitException {
      rethrow;
    } catch (e) {
      throw AppInitException('SupabaseService failed to initialize', cause: e);
    }
  }

  static CacheService _initCache() {
    final service = CacheService(
      maxMemoryEntries: 200,
      diskCacheDirName: 'arenda_cache',
    );
    debugPrint('[AppInitializer] ✓ CacheService ready');
    return service;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXCEPTION
// ─────────────────────────────────────────────────────────────────────────────

class AppInitException implements Exception {
  final String message;
  final Object? cause;
  const AppInitException(this.message, {this.cause});

  @override
  String toString() =>
      'AppInitException: $message${cause != null ? ' → $cause' : ''}';
}
