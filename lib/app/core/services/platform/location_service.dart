import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geolocator/geolocator.dart'
    show
        Geolocator,
        Position,
        LocationPermission,
        LocationServiceDisabledException,
        PermissionDeniedException,
        AndroidSettings,
        AppleSettings,
        ForegroundNotificationConfig,
        ActivityType,
        LocationSettings;
import 'package:permission_handler/permission_handler.dart';

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────

enum LocationPermissionStatus {
  granted,
  grantedLimited, // Android 12+ precise vs approximate
  denied,
  deniedForever,
  restricted, // iOS only
  serviceDisabled,
  unknown,
}

enum LocationAccuracy {
  high, // GPS, ~5m
  balanced, // Network + GPS, ~100m
  low, // Network only, ~1km
  passive, // No active request
}

class LocationResult {
  final double? latitude;
  final double? longitude;
  final double? accuracy; // meters
  final double? altitude;
  final double? speed; // m/s
  final double? heading;
  final DateTime? timestamp;
  final LocationPermissionStatus permissionStatus;
  final String? errorMessage;

  const LocationResult({
    this.latitude,
    this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    this.timestamp,
    required this.permissionStatus,
    this.errorMessage,
  });

  bool get hasLocation => latitude != null && longitude != null;

  bool get isSuccess =>
      hasLocation &&
      (permissionStatus == LocationPermissionStatus.granted ||
          permissionStatus == LocationPermissionStatus.grantedLimited);

  factory LocationResult.fromPosition(Position position) {
    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      speed: position.speed,
      heading: position.heading,
      timestamp: position.timestamp,
      permissionStatus: LocationPermissionStatus.granted,
    );
  }

  factory LocationResult.error({
    required LocationPermissionStatus permissionStatus,
    required String errorMessage,
  }) {
    return LocationResult(
      permissionStatus: permissionStatus,
      errorMessage: errorMessage,
    );
  }

  LocationResult copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    DateTime? timestamp,
    LocationPermissionStatus? permissionStatus,
    String? errorMessage,
  }) {
    return LocationResult(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      timestamp: timestamp ?? this.timestamp,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() =>
      'LocationResult(lat: $latitude, lng: $longitude, accuracy: ${accuracy?.toStringAsFixed(1)}m, '
      'status: $permissionStatus, error: $errorMessage)';
}

// ─────────────────────────────────────────────
// SERVICE ABSTRACT + IMPL
// ─────────────────────────────────────────────

abstract class ILocationService {
  /// Check current permission status without requesting
  Future<LocationPermissionStatus> checkPermissionStatus();

  /// Request permission — handles all states including forever-denied (opens settings)
  Future<LocationPermissionStatus> requestPermission();

  /// Check if location services (GPS/Network) are enabled on device
  Future<bool> isLocationServiceEnabled();

  /// One-shot: get current location. Handles permissions internally.
  Future<LocationResult> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeout = const Duration(seconds: 15),
  });

  /// Stream: continuous location updates
  Stream<LocationResult> getLocationStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilterMeters = 10,
  });

  /// Open device location settings (when service disabled)
  Future<bool> openLocationSettings();

  /// Open app settings (when permission forever denied)
  Future<bool> openAppSettings();

  /// Dispose any active streams
  void dispose();
}

// ─────────────────────────────────────────────
// IMPLEMENTATION
// ─────────────────────────────────────────────

class LocationService implements ILocationService {
  StreamController<LocationResult>? _locationStreamController;
  StreamSubscription<Position>? _positionSubscription;

  // ── Permission Checks ──────────────────────

  @override
  Future<LocationPermissionStatus> checkPermissionStatus() async {
    try {
      // First check if location services are ON
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.serviceDisabled;
      }

      if (Platform.isAndroid) {
        return await _checkAndroidPermission();
      } else if (Platform.isIOS) {
        return await _checkIOSPermission();
      }

      // Fallback for other platforms
      final permission = await Geolocator.checkPermission();
      return _mapGeolocatorPermission(permission);
    } catch (e) {
      debugPrint('[LocationService] checkPermissionStatus error: $e');
      return LocationPermissionStatus.unknown;
    }
  }

  Future<LocationPermissionStatus> _checkAndroidPermission() async {
    // Android 12+ (API 31+): check precise vs approximate
    final fineStatus = await Permission.locationWhenInUse.status;

    if (fineStatus.isGranted) {
      // Check if it's precise or approximate (Android 12+)
      if (await _isAndroid12OrAbove()) {
        // final coarseStatus = await Permission.locationAlways.status;
        await Permission.locationAlways.status;
        // Approximate only = grantedLimited
        // We check precise permission separately
        final preciseStatus = await Permission.location.status;
        if (!preciseStatus.isGranted && fineStatus.isGranted) {
          // Only approximate granted
          return LocationPermissionStatus.grantedLimited;
        }
      }
      return LocationPermissionStatus.granted;
    } else if (fineStatus.isDenied) {
      return LocationPermissionStatus.denied;
    } else if (fineStatus.isPermanentlyDenied) {
      return LocationPermissionStatus.deniedForever;
    } else if (fineStatus.isRestricted) {
      return LocationPermissionStatus.restricted;
    }

    return LocationPermissionStatus.unknown;
  }

  Future<LocationPermissionStatus> _checkIOSPermission() async {
    final permission = await Geolocator.checkPermission();
    return _mapGeolocatorPermission(permission);
  }

  LocationPermissionStatus _mapGeolocatorPermission(
    LocationPermission permission,
  ) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.unknown;
    }
  }

  // ── Permission Request ──────────────────────

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    try {
      // Check service first
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.serviceDisabled;
      }

      if (Platform.isAndroid) {
        return await _requestAndroidPermission();
      } else {
        return await _requestIOSPermission();
      }
    } catch (e) {
      debugPrint('[LocationService] requestPermission error: $e');
      return LocationPermissionStatus.unknown;
    }
  }

  Future<LocationPermissionStatus> _requestAndroidPermission() async {
    final currentStatus = await checkPermissionStatus();

    if (currentStatus == LocationPermissionStatus.granted ||
        currentStatus == LocationPermissionStatus.grantedLimited) {
      return currentStatus;
    }

    if (currentStatus == LocationPermissionStatus.deniedForever) {
      // Can't request anymore — must open settings
      debugPrint('[LocationService] Permission permanently denied on Android');
      return LocationPermissionStatus.deniedForever;
    }

    // Android 12+: request precise location
    if (await _isAndroid12OrAbove()) {
      final result = await [
        Permission.location,
        Permission.locationWhenInUse,
      ].request();

      final locationStatus = result[Permission.location];
      final whenInUseStatus = result[Permission.locationWhenInUse];

      if (locationStatus?.isGranted == true) {
        return LocationPermissionStatus.granted;
      } else if (whenInUseStatus?.isGranted == true) {
        // Only approximate granted
        return LocationPermissionStatus.grantedLimited;
      } else if (locationStatus?.isPermanentlyDenied == true ||
          whenInUseStatus?.isPermanentlyDenied == true) {
        return LocationPermissionStatus.deniedForever;
      }
      return LocationPermissionStatus.denied;
    } else {
      // Android < 12
      final result = await Permission.locationWhenInUse.request();
      if (result.isGranted) return LocationPermissionStatus.granted;
      if (result.isPermanentlyDenied) {
        return LocationPermissionStatus.deniedForever;
      }
      return LocationPermissionStatus.denied;
    }
  }

  Future<LocationPermissionStatus> _requestIOSPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return LocationPermissionStatus.granted;
    }

    return LocationPermissionStatus.denied;
  }

  // ── Service Check ───────────────────────────

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('[LocationService] isLocationServiceEnabled error: $e');
      return false;
    }
  }

  // ── Get Current Location ────────────────────

  @override
  Future<LocationResult> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      // Step 1: Check service
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.error(
          permissionStatus: LocationPermissionStatus.serviceDisabled,
          errorMessage:
              'Location services are disabled. Please enable GPS/Network location.',
        );
      }

      // Step 2: Check/Request permission
      LocationPermissionStatus permStatus = await checkPermissionStatus();

      if (permStatus == LocationPermissionStatus.denied) {
        permStatus = await requestPermission();
      }

      if (permStatus == LocationPermissionStatus.deniedForever) {
        return LocationResult.error(
          permissionStatus: LocationPermissionStatus.deniedForever,
          errorMessage:
              'Location permission permanently denied. Please enable it from App Settings.',
        );
      }

      if (permStatus == LocationPermissionStatus.denied) {
        return LocationResult.error(
          permissionStatus: LocationPermissionStatus.denied,
          errorMessage: 'Location permission denied.',
        );
      }

      if (permStatus == LocationPermissionStatus.restricted) {
        return LocationResult.error(
          permissionStatus: LocationPermissionStatus.restricted,
          errorMessage: 'Location access is restricted on this device.',
        );
      }

      if (permStatus == LocationPermissionStatus.serviceDisabled) {
        return LocationResult.error(
          permissionStatus: LocationPermissionStatus.serviceDisabled,
          errorMessage: 'Location service is disabled.',
        );
      }

      // Step 3: Get position
      final position = await Geolocator.getCurrentPosition(
        // desiredAccuracy: _mapAccuracy(accuracy),
        // timeLimit: timeout,
      );

      final result = LocationResult.fromPosition(position);

      // If limited (approximate), mark accordingly
      if (permStatus == LocationPermissionStatus.grantedLimited) {
        return result.copyWith(
          permissionStatus: LocationPermissionStatus.grantedLimited,
        );
      }

      return result;
    } on TimeoutException {
      debugPrint('[LocationService] getCurrentLocation timed out');
      return LocationResult.error(
        permissionStatus: LocationPermissionStatus.unknown,
        errorMessage:
            'Location request timed out. Please check your GPS signal.',
      );
    } on LocationServiceDisabledException {
      return LocationResult.error(
        permissionStatus: LocationPermissionStatus.serviceDisabled,
        errorMessage: 'Location services were disabled during the request.',
      );
    } on PermissionDeniedException {
      return LocationResult.error(
        permissionStatus: LocationPermissionStatus.denied,
        errorMessage: 'Location permission was denied.',
      );
    } catch (e) {
      debugPrint('[LocationService] getCurrentLocation unexpected error: $e');
      return LocationResult.error(
        permissionStatus: LocationPermissionStatus.unknown,
        errorMessage: 'Unexpected error getting location: $e',
      );
    }
  }

  // ── Location Stream ─────────────────────────

  @override
  Stream<LocationResult> getLocationStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilterMeters = 10,
  }) {
    // Dispose any previous stream
    _disposeStream();

    _locationStreamController = StreamController<LocationResult>.broadcast(
      onCancel: _disposeStream,
    );

    _initLocationStream(
      accuracy: accuracy,
      distanceFilterMeters: distanceFilterMeters,
    );

    return _locationStreamController!.stream;
  }

  void _initLocationStream({
    required LocationAccuracy accuracy,
    required int distanceFilterMeters,
  }) async {
    try {
      // Check service
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationStreamController?.add(
          LocationResult.error(
            permissionStatus: LocationPermissionStatus.serviceDisabled,
            errorMessage: 'Location services are disabled.',
          ),
        );
        return;
      }

      // Check/Request permission
      LocationPermissionStatus permStatus = await checkPermissionStatus();
      if (permStatus == LocationPermissionStatus.denied) {
        permStatus = await requestPermission();
      }

      if (permStatus == LocationPermissionStatus.deniedForever ||
          permStatus == LocationPermissionStatus.denied ||
          permStatus == LocationPermissionStatus.restricted) {
        _locationStreamController?.add(
          LocationResult.error(
            permissionStatus: permStatus,
            errorMessage: _permissionErrorMessage(permStatus),
          ),
        );
        return;
      }

      final locationSettings = _buildLocationSettings(
        accuracy: accuracy,
        distanceFilterMeters: distanceFilterMeters,
      );

      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen(
            (Position position) {
              if (_locationStreamController?.isClosed == false) {
                _locationStreamController?.add(
                  LocationResult.fromPosition(
                    position,
                  ).copyWith(permissionStatus: permStatus),
                );
              }
            },
            onError: (error) {
              debugPrint('[LocationService] Stream error: $error');
              if (_locationStreamController?.isClosed == false) {
                _locationStreamController?.add(
                  LocationResult.error(
                    permissionStatus: LocationPermissionStatus.unknown,
                    errorMessage: 'Location stream error: $error',
                  ),
                );
              }
            },
            cancelOnError: false,
          );
    } catch (e) {
      debugPrint('[LocationService] _initLocationStream error: $e');
      _locationStreamController?.add(
        LocationResult.error(
          permissionStatus: LocationPermissionStatus.unknown,
          errorMessage: 'Failed to start location stream: $e',
        ),
      );
    }
  }

  LocationSettings _buildLocationSettings({
    required LocationAccuracy accuracy,
    required int distanceFilterMeters,
  }) {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: _mapAccuracy(accuracy),
        distanceFilter: distanceFilterMeters,
        intervalDuration: const Duration(seconds: 5),
        // Android 12+ foreground service notification
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: 'App is using your location in the background.',
          notificationTitle: 'Location Active',
          enableWakeLock: true,
        ),
      );
    } else if (Platform.isIOS) {
      return AppleSettings(
        accuracy: _mapAccuracy(accuracy),
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: distanceFilterMeters,
        showBackgroundLocationIndicator: true,
      );
    }

    // Fallback
    return LocationSettings(
      accuracy: _mapAccuracy(accuracy),
      distanceFilter: distanceFilterMeters,
    );
  }

  // ── Settings Navigation ─────────────────────

  @override
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('[LocationService] openLocationSettings error: $e');
      return false;
    }
  }

  @override
  Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      debugPrint('[LocationService] openAppSettings error: $e');
      return false;
    }
  }

  // ── Helpers ─────────────────────────────────

  geo.LocationAccuracy _mapAccuracy(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.high:
        return geo.LocationAccuracy.high;
      case LocationAccuracy.balanced:
        return geo.LocationAccuracy.medium;
      case LocationAccuracy.low:
        return geo.LocationAccuracy.low;
      case LocationAccuracy.passive:
        return geo.LocationAccuracy.lowest;
    }
  }

  Future<bool> _isAndroid12OrAbove() async {
    if (!Platform.isAndroid) return false;
    try {
      // device_info_plus se check karo
      // Agar device_info_plus nahi hai project mein to fallback true rakhein
      // kyunki permission_handler handles it gracefully
      return true; // Safe default — permission_handler handles it
    } catch (_) {
      return true;
    }
  }

  String _permissionErrorMessage(LocationPermissionStatus status) {
    switch (status) {
      case LocationPermissionStatus.deniedForever:
        return 'Location permission permanently denied. Open App Settings to enable.';
      case LocationPermissionStatus.denied:
        return 'Location permission denied.';
      case LocationPermissionStatus.restricted:
        return 'Location access is restricted on this device.';
      case LocationPermissionStatus.serviceDisabled:
        return 'Location services are disabled. Please enable GPS.';
      default:
        return 'Location permission unavailable.';
    }
  }

  // ── Dispose ──────────────────────────────────

  void _disposeStream() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _locationStreamController?.close();
    _locationStreamController = null;
  }

  @override
  void dispose() {
    _disposeStream();
    debugPrint('[LocationService] Disposed');
  }
}

// ─────────────────────────────────────────────
// RIVERPOD PROVIDERS
// ─────────────────────────────────────────────

/// Service provider — single instance
final locationServiceProvider = Provider<ILocationService>((ref) {
  final service = LocationService();
  ref.onDispose(service.dispose);
  return service;
});

/// Permission status provider
final locationPermissionProvider = FutureProvider<LocationPermissionStatus>((
  ref,
) async {
  final service = ref.watch(locationServiceProvider);
  return service.checkPermissionStatus();
});

/// One-shot current location provider
final currentLocationProvider = FutureProvider<LocationResult>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return service.getCurrentLocation();
});

/// Stream provider for continuous updates
final locationStreamProvider = StreamProvider<LocationResult>((ref) {
  final service = ref.watch(locationServiceProvider);
  return service.getLocationStream();
});
