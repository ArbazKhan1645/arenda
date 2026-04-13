import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CACHE KEYS — centralized
// ─────────────────────────────────────────────────────────────────────────────

abstract class CacheKeys {
  // ── Route / Map
  static const String routes = 'routes_list';
  static const String activeRoute = 'active_route';
  static const String warehouseList = 'warehouse_list';
  static const String intercityRoutes = 'intercity_routes';
  static const String serviceAreas = 'service_areas';

  // ── User
  static const String driverProfile = 'driver_profile';
  static const String adminProfile = 'admin_profile';

  // ── Map tiles / geo
  static const String geocodeResults = 'geocode_results';

  // ── Reports
  static const String reportSummary = 'report_summary';

  /// Namespaced key for per-entity caching
  static String routeById(String id) => 'route_$id';
  static String warehouseById(String id) => 'warehouse_$id';
  static String stopsByRoute(String id) => 'stops_route_$id';
  static String chatHistory(String id) => 'chat_$id';
}

// ─────────────────────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────────────────────

class _CacheEntry {
  final dynamic data;
  final DateTime createdAt;
  final Duration? ttl;

  _CacheEntry({
    required this.data,
    required this.createdAt,
    this.ttl,
  });

  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().isAfter(createdAt.add(ttl!));
  }

  Map<String, dynamic> toJson() => {
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'ttlMs': ttl?.inMilliseconds,
      };

  factory _CacheEntry.fromJson(Map<String, dynamic> json) => _CacheEntry(
        data: json['data'],
        createdAt: DateTime.parse(json['createdAt'] as String),
        ttl: json['ttlMs'] != null
            ? Duration(milliseconds: json['ttlMs'] as int)
            : null,
      );
}

class CacheStats {
  final int memoryEntries;
  final int diskEntries;
  final int memoryHits;
  final int diskHits;
  final int misses;
  final int evictions;

  const CacheStats({
    required this.memoryEntries,
    required this.diskEntries,
    required this.memoryHits,
    required this.diskHits,
    required this.misses,
    required this.evictions,
  });

  double get hitRate {
    final total = memoryHits + diskHits + misses;
    if (total == 0) return 0;
    return (memoryHits + diskHits) / total;
  }

  @override
  String toString() => 'CacheStats(mem: $memoryEntries, disk: $diskEntries, '
      'hits: ${memoryHits + diskHits}, misses: $misses, '
      'hitRate: ${(hitRate * 100).toStringAsFixed(1)}%)';
}

// ─────────────────────────────────────────────────────────────────────────────
// DEFAULT TTLs
// ─────────────────────────────────────────────────────────────────────────────

abstract class CacheTTL {
  static const Duration short = Duration(minutes: 5);
  static const Duration medium = Duration(minutes: 30);
  static const Duration long = Duration(hours: 6);
  static const Duration veryLong = Duration(hours: 24);
  static const Duration persistent = Duration(days: 30);

  // Domain-specific
  static const Duration geocode = Duration(days: 7);
  static const Duration routeList = Duration(minutes: 10);
  static const Duration warehouse = Duration(hours: 1);
  static const Duration userProfile = Duration(hours: 12);
  static const Duration report = Duration(minutes: 15);
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERFACE
// ─────────────────────────────────────────────────────────────────────────────

abstract class ICacheService {
  /// Store value in memory + disk with optional TTL
  Future<void> set(
    String key,
    dynamic value, {
    Duration? ttl,
    bool diskPersist,
  });

  /// Retrieve. Returns null on miss or expired.
  Future<T?> get<T>(String key);

  /// Check existence without fetching
  Future<bool> has(String key);

  /// Remove single key from memory + disk
  Future<void> remove(String key);

  /// Remove all keys with given prefix (e.g. 'route_' wipes all route caches)
  Future<void> removeByPrefix(String prefix);

  /// Clear entire in-memory cache
  Future<void> clearMemory();

  /// Clear entire disk cache
  Future<void> clearDisk();

  /// Clear both
  Future<void> clearAll();

  /// Remove all expired entries from memory + disk
  Future<void> evictExpired();

  CacheStats get stats;
}

// ─────────────────────────────────────────────────────────────────────────────
// IMPLEMENTATION — LRU in-memory + disk persistence
// ─────────────────────────────────────────────────────────────────────────────

class CacheService implements ICacheService {
  /// Max entries to keep in memory before LRU eviction
  final int maxMemoryEntries;

  /// Subdirectory name inside app cache dir
  final String diskCacheDirName;

  // In-memory store: insertion-ordered LinkedHashMap = LRU behaviour
  final Map<String, _CacheEntry> _memCache = {};

  // Disk cache dir — initialized lazily
  Directory? _cacheDir;

  // Stats
  int _memHits = 0;
  int _diskHits = 0;
  int _misses = 0;
  int _evictions = 0;

  // Periodic eviction timer
  Timer? _evictionTimer;

  CacheService({
    this.maxMemoryEntries = 200,
    this.diskCacheDirName = 'app_cache',
  }) {
    // Evict expired entries every 10 minutes
    _evictionTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => evictExpired(),
    );
  }

  // ── DISK DIR ─────────────────────────────────────────────────────────────────

  Future<Directory> get _dir async {
    if (_cacheDir != null) return _cacheDir!;
    final base = await getApplicationCacheDirectory();
    final dir = Directory('${base.path}/$diskCacheDirName');
    if (!dir.existsSync()) await dir.create(recursive: true);
    _cacheDir = dir;
    return dir;
  }

  File _diskFile(Directory dir, String key) {
    // Sanitize key → safe filename
    final safe = Uri.encodeComponent(key);
    return File('${dir.path}/$safe.json');
  }

  // ── SET ──────────────────────────────────────────────────────────────────────

  @override
  Future<void> set(
    String key,
    dynamic value, {
    Duration? ttl,
    bool diskPersist = true,
  }) async {
    final entry = _CacheEntry(
      data: value,
      createdAt: DateTime.now(),
      ttl: ttl,
    );

    // Memory: LRU eviction when full
    if (_memCache.length >= maxMemoryEntries && !_memCache.containsKey(key)) {
      _evictOldestMemoryEntry();
    }
    _memCache[key] = entry;

    // Disk persistence
    if (diskPersist) {
      await _writeToDisk(key, entry);
    }
  }

  // ── GET ──────────────────────────────────────────────────────────────────────

  @override
  Future<T?> get<T>(String key) async {
    // 1. Memory hit
    final memEntry = _memCache[key];
    if (memEntry != null) {
      if (memEntry.isExpired) {
        _memCache.remove(key);
        await _removeFromDisk(key);
        _misses++;
        return null;
      }
      _memHits++;
      // LRU: move to end (most recently used)
      _memCache.remove(key);
      _memCache[key] = memEntry;
      return memEntry.data as T?;
    }

    // 2. Disk hit
    final diskEntry = await _readFromDisk(key);
    if (diskEntry != null) {
      if (diskEntry.isExpired) {
        await _removeFromDisk(key);
        _misses++;
        return null;
      }
      _diskHits++;
      // Promote to memory
      _memCache[key] = diskEntry;
      return diskEntry.data as T?;
    }

    // 3. Miss
    _misses++;
    return null;
  }

  // ── HAS ──────────────────────────────────────────────────────────────────────

  @override
  Future<bool> has(String key) async {
    final memEntry = _memCache[key];
    if (memEntry != null && !memEntry.isExpired) return true;

    final diskEntry = await _readFromDisk(key);
    return diskEntry != null && !diskEntry.isExpired;
  }

  // ── REMOVE ───────────────────────────────────────────────────────────────────

  @override
  Future<void> remove(String key) async {
    _memCache.remove(key);
    await _removeFromDisk(key);
  }

  @override
  Future<void> removeByPrefix(String prefix) async {
    // Memory
    final memKeys = _memCache.keys.where((k) => k.startsWith(prefix)).toList();
    for (final k in memKeys) {
      _memCache.remove(k);
    }

    // Disk
    try {
      final dir = await _dir;
      final files = dir.listSync().whereType<File>();
      for (final file in files) {
        final filename = Uri.decodeComponent(
          file.uri.pathSegments.last.replaceAll('.json', ''),
        );
        if (filename.startsWith(prefix)) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('[CacheService] removeByPrefix disk error: $e');
    }
  }

  // ── CLEAR ────────────────────────────────────────────────────────────────────

  @override
  Future<void> clearMemory() async {
    _memCache.clear();
    debugPrint('[CacheService] Memory cache cleared');
  }

  @override
  Future<void> clearDisk() async {
    try {
      final dir = await _dir;
      if (dir.existsSync()) {
        await dir.delete(recursive: true);
        await dir.create();
      }
      debugPrint('[CacheService] Disk cache cleared');
    } catch (e) {
      debugPrint('[CacheService] clearDisk error: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    await Future.wait([clearMemory(), clearDisk()]);
  }

  // ── EVICTION ─────────────────────────────────────────────────────────────────

  @override
  Future<void> evictExpired() async {
    int count = 0;

    // Memory
    final expiredMem = _memCache.entries
        .where((e) => e.value.isExpired)
        .map((e) => e.key)
        .toList();
    for (final k in expiredMem) {
      _memCache.remove(k);
      count++;
    }

    // Disk
    try {
      final dir = await _dir;
      final files = dir.listSync().whereType<File>();
      for (final file in files) {
        try {
          final raw = await file.readAsString();
          final entry = _CacheEntry.fromJson(
            jsonDecode(raw) as Map<String, dynamic>,
          );
          if (entry.isExpired) {
            await file.delete();
            count++;
          }
        } catch (_) {
          // Corrupted file — delete it
          await file.delete();
          count++;
        }
      }
    } catch (e) {
      debugPrint('[CacheService] evictExpired disk error: $e');
    }

    _evictions += count;
    if (count > 0) {
      debugPrint('[CacheService] Evicted $count expired entries');
    }
  }

  // ── STATS ────────────────────────────────────────────────────────────────────

  @override
  CacheStats get stats {
    int diskCount = 0;
    try {
      final dir = _cacheDir;
      if (dir != null && dir.existsSync()) {
        diskCount = dir.listSync().whereType<File>().length;
      }
    } catch (_) {}

    return CacheStats(
      memoryEntries: _memCache.length,
      diskEntries: diskCount,
      memoryHits: _memHits,
      diskHits: _diskHits,
      misses: _misses,
      evictions: _evictions,
    );
  }

  // ── DISK HELPERS ─────────────────────────────────────────────────────────────

  Future<void> _writeToDisk(String key, _CacheEntry entry) async {
    try {
      final dir = await _dir;
      final file = _diskFile(dir, key);
      final json = jsonEncode(entry.toJson());
      await file.writeAsString(json, flush: true);
    } catch (e) {
      debugPrint('[CacheService] _writeToDisk error ($key): $e');
    }
  }

  Future<_CacheEntry?> _readFromDisk(String key) async {
    try {
      final dir = await _dir;
      final file = _diskFile(dir, key);
      if (!file.existsSync()) return null;
      final raw = await file.readAsString();
      return _CacheEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[CacheService] _readFromDisk error ($key): $e');
      return null;
    }
  }

  Future<void> _removeFromDisk(String key) async {
    try {
      final dir = await _dir;
      final file = _diskFile(dir, key);
      if (file.existsSync()) await file.delete();
    } catch (e) {
      debugPrint('[CacheService] _removeFromDisk error ($key): $e');
    }
  }

  // ── LRU HELPERS ──────────────────────────────────────────────────────────────

  void _evictOldestMemoryEntry() {
    if (_memCache.isEmpty) return;
    final oldestKey = _memCache.keys.first;
    _memCache.remove(oldestKey);
    _evictions++;
    debugPrint('[CacheService] LRU evicted: $oldestKey');
  }

  // ── DISPOSE ───────────────────────────────────────────────────────────────────

  void dispose() {
    _evictionTimer?.cancel();
    _evictionTimer = null;
    debugPrint('[CacheService] disposed');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GENERIC CACHED FETCHER — use this in repositories
// ─────────────────────────────────────────────────────────────────────────────
//
// Usage in a repository:
// ```dart
// final routes = await _cache.getOrFetch(
//   key: CacheKeys.routes,
//   ttl: CacheTTL.routeList,
//   fetch: () => _supabase.from('routes').select().then(...),
// );
// ```

extension CacheServiceX on CacheService {
  Future<T> getOrFetch<T>({
    required String key,
    required Future<T> Function() fetch,
    Duration? ttl,
    bool diskPersist = true,
  }) async {
    final cached = await get<T>(key);
    if (cached != null) return cached;

    final fresh = await fetch();
    await set(key, fresh, ttl: ttl, diskPersist: diskPersist);
    return fresh;
  }

  /// Like getOrFetch but returns stale data while revalidating in background
  Future<T?> staleWhileRevalidate<T>({
    required String key,
    required Future<T> Function() fetch,
    Duration? ttl,
  }) async {
    final cached = await get<T>(key);

    // Trigger background refresh regardless of staleness
    fetch().then((fresh) async {
      await set(key, fresh, ttl: ttl);
    }).catchError((Object e) {
      debugPrint('[CacheService] staleWhileRevalidate bg error ($key): $e');
    });

    return cached;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RIVERPOD PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

/// Singleton cache service — auto-disposed
final cacheServiceProvider = Provider<CacheService>((ref) {
  final service = CacheService(
    maxMemoryEntries: 200,
    diskCacheDirName: 'app_cache',
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Expose stats as a provider for debug screens
final cacheStatsProvider = Provider<CacheStats>((ref) {
  return ref.watch(cacheServiceProvider).stats;
});
