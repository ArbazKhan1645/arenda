import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STORAGE KEYS — centralized, no magic strings anywhere in app
// ─────────────────────────────────────────────────────────────────────────────

abstract class StorageKeys {
  // ── Auth
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';

  // ── Onboarding / App State
  static const String isOnboarded = 'is_onboarded';
  static const String appTheme = 'app_theme';
  static const String appLocale = 'app_locale';
  static const String lastSyncTime = 'last_sync_time';

  // ── Driver / Route (RouteFlow specific)
  static const String activeRouteId = 'active_route_id';
  static const String driverStatus = 'driver_status';
  static const String fcmToken = 'fcm_token';
}

// ─────────────────────────────────────────────────────────────────────────────
// EXCEPTIONS
// ─────────────────────────────────────────────────────────────────────────────

class StorageException implements Exception {
  final String message;
  final Object? cause;
  const StorageException(this.message, {this.cause});

  @override
  String toString() =>
      'StorageException: $message${cause != null ? ' ($cause)' : ''}';
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERFACE
// ─────────────────────────────────────────────────────────────────────────────

abstract class IStorageService {
  // ── Regular (SharedPreferences) ─────────────────────────────────────────────

  Future<void> setString(String key, String value);
  Future<String?> getString(String key);

  Future<void> setBool(String key, {required bool value});
  Future<bool?> getBool(String key);

  Future<void> setInt(String key, int value);
  Future<int?> getInt(String key);

  Future<void> setDouble(String key, double value);
  Future<double?> getDouble(String key);

  /// Serialize any Map/List to JSON and store
  Future<void> setObject(String key, Map<String, dynamic> value);
  Future<Map<String, dynamic>?> getObject(String key);

  Future<void> setStringList(String key, List<String> value);
  Future<List<String>?> getStringList(String key);

  Future<bool> remove(String key);
  Future<bool> containsKey(String key);

  /// Clear all non-secure prefs (does NOT touch secure storage)
  Future<bool> clearAll();

  // ── Secure (flutter_secure_storage) ─────────────────────────────────────────

  Future<void> setSecure(String key, String value);
  Future<String?> getSecure(String key);
  Future<void> removeSecure(String key);
  Future<void> clearAllSecure();

  /// True when secure storage is available on this device
  Future<bool> get isSecureStorageAvailable;

  // ── Auth helpers (convenience) ───────────────────────────────────────────────

  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<({String? accessToken, String? refreshToken})> getAuthTokens();

  Future<void> clearAuthTokens();
}

// ─────────────────────────────────────────────────────────────────────────────
// IMPLEMENTATION
// ─────────────────────────────────────────────────────────────────────────────

class StorageService implements IStorageService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secure;

  StorageService._({
    required SharedPreferences prefs,
    required FlutterSecureStorage secure,
  })  : _prefs = prefs,
        _secure = secure;

  /// Factory async initializer — call once at app startup
  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Android: encrypted with EncryptedSharedPreferences (API 23+)
    // iOS: stored in Keychain
    const secureOptions = AndroidOptions(
      resetOnError: true, // prevents lockout on keystore corruption
    );
    const iosOptions = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
      // first_unlock = accessible after first device unlock (good for background tasks)
    );

    const secure = FlutterSecureStorage(
      aOptions: secureOptions,
      iOptions: iosOptions,
    );

    return StorageService._(prefs: prefs, secure: secure);
  }

  // ── STRING ──────────────────────────────────────────────────────────────────

  @override
  Future<void> setString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
    } catch (e) {
      throw StorageException('setString failed for key: $key', cause: e);
    }
  }

  @override
  Future<String?> getString(String key) async {
    try {
      return _prefs.getString(key);
    } catch (e) {
      debugPrint('[StorageService] getString error ($key): $e');
      return null;
    }
  }

  // ── BOOL ────────────────────────────────────────────────────────────────────

  @override
  Future<void> setBool(String key, {required bool value}) async {
    try {
      await _prefs.setBool(key, value);
    } catch (e) {
      throw StorageException('setBool failed for key: $key', cause: e);
    }
  }

  @override
  Future<bool?> getBool(String key) async {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      debugPrint('[StorageService] getBool error ($key): $e');
      return null;
    }
  }

  // ── INT ─────────────────────────────────────────────────────────────────────

  @override
  Future<void> setInt(String key, int value) async {
    try {
      await _prefs.setInt(key, value);
    } catch (e) {
      throw StorageException('setInt failed for key: $key', cause: e);
    }
  }

  @override
  Future<int?> getInt(String key) async {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      debugPrint('[StorageService] getInt error ($key): $e');
      return null;
    }
  }

  // ── DOUBLE ──────────────────────────────────────────────────────────────────

  @override
  Future<void> setDouble(String key, double value) async {
    try {
      await _prefs.setDouble(key, value);
    } catch (e) {
      throw StorageException('setDouble failed for key: $key', cause: e);
    }
  }

  @override
  Future<double?> getDouble(String key) async {
    try {
      return _prefs.getDouble(key);
    } catch (e) {
      debugPrint('[StorageService] getDouble error ($key): $e');
      return null;
    }
  }

  // ── OBJECT (JSON) ────────────────────────────────────────────────────────────

  @override
  Future<void> setObject(String key, Map<String, dynamic> value) async {
    try {
      final json = jsonEncode(value);
      await _prefs.setString(key, json);
    } catch (e) {
      throw StorageException('setObject failed for key: $key', cause: e);
    }
  }

  @override
  Future<Map<String, dynamic>?> getObject(String key) async {
    try {
      final raw = _prefs.getString(key);
      if (raw == null) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[StorageService] getObject error ($key): $e');
      return null;
    }
  }

  // ── STRING LIST ──────────────────────────────────────────────────────────────

  @override
  Future<void> setStringList(String key, List<String> value) async {
    try {
      await _prefs.setStringList(key, value);
    } catch (e) {
      throw StorageException('setStringList failed for key: $key', cause: e);
    }
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    try {
      return _prefs.getStringList(key);
    } catch (e) {
      debugPrint('[StorageService] getStringList error ($key): $e');
      return null;
    }
  }

  // ── REMOVE / CONTAINS / CLEAR ────────────────────────────────────────────────

  @override
  Future<bool> remove(String key) async {
    try {
      return _prefs.remove(key);
    } catch (e) {
      debugPrint('[StorageService] remove error ($key): $e');
      return false;
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    return _prefs.containsKey(key);
  }

  @override
  Future<bool> clearAll() async {
    try {
      return _prefs.clear();
    } catch (e) {
      debugPrint('[StorageService] clearAll error: $e');
      return false;
    }
  }

  // ── SECURE STORAGE ───────────────────────────────────────────────────────────

  @override
  Future<void> setSecure(String key, String value) async {
    try {
      await _secure.write(key: key, value: value);
    } catch (e) {
      throw StorageException('setSecure failed for key: $key', cause: e);
    }
  }

  @override
  Future<String?> getSecure(String key) async {
    try {
      return await _secure.read(key: key);
    } catch (e) {
      debugPrint('[StorageService] getSecure error ($key): $e');
      // On Android, if keystore is corrupted, resetOnError handles it
      return null;
    }
  }

  @override
  Future<void> removeSecure(String key) async {
    try {
      await _secure.delete(key: key);
    } catch (e) {
      debugPrint('[StorageService] removeSecure error ($key): $e');
    }
  }

  @override
  Future<void> clearAllSecure() async {
    try {
      await _secure.deleteAll();
    } catch (e) {
      debugPrint('[StorageService] clearAllSecure error: $e');
    }
  }

  @override
  Future<bool> get isSecureStorageAvailable async {
    try {
      await _secure.write(key: '__health_check__', value: '1');
      await _secure.delete(key: '__health_check__');
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── AUTH CONVENIENCE ─────────────────────────────────────────────────────────

  @override
  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    // Tokens ALWAYS go to secure storage — never SharedPreferences
    await Future.wait([
      setSecure(StorageKeys.authToken, accessToken),
      setSecure(StorageKeys.refreshToken, refreshToken),
    ]);
  }

  @override
  Future<({String? accessToken, String? refreshToken})> getAuthTokens() async {
    final results = await Future.wait([
      getSecure(StorageKeys.authToken),
      getSecure(StorageKeys.refreshToken),
    ]);
    return (accessToken: results[0], refreshToken: results[1]);
  }

  @override
  Future<void> clearAuthTokens() async {
    await Future.wait([
      removeSecure(StorageKeys.authToken),
      removeSecure(StorageKeys.refreshToken),
    ]);
  }

  // ── FULL LOGOUT WIPE ─────────────────────────────────────────────────────────

  /// Wipes BOTH SharedPreferences AND secure storage — use on logout
  Future<void> clearEverything() async {
    await Future.wait([
      clearAll(),
      clearAllSecure(),
    ]);
    debugPrint('[StorageService] Full wipe complete');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RIVERPOD PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError(
    'storageServiceProvider must be overridden in ProviderScope. '
    'Call StorageService.init() in main() and pass it as an override.',
  );
});
