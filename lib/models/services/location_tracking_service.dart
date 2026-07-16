import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:roamio_frontend/models/services/trip_location_service.dart';

/// Manages a single long-lived GPS stream for whichever trip is currently
/// active, and pushes each position update to the backend via
/// TripLocationService.
///
/// This is intentionally NOT part of TripLocationRepository/Service — those
/// are one-shot request wrappers, while this holds ongoing state (a stream
/// subscription tied to a trip's active/completed lifecycle). Start it when
/// a trip becomes Active, stop it when the trip ends or the user leaves.
///
/// Tier 2 background support: keeps sending updates while the app is
/// backgrounded but not killed. Requires:
///   - Android: foreground service notification (configured below) — Android
///     kills background location access without one.
///   - iOS: `UIBackgroundModes: [location]` in Info.plist (already added)
///     plus the "Background Modes > Location updates" capability enabled in
///     Xcode's Signing & Capabilities tab for the Runner target.
/// Does NOT survive the app being fully killed/swiped away — that needs a
/// real background-service architecture (tier 3), not just a stream.
class LocationTrackingService {
  LocationTrackingService._internal({TripLocationService? tripLocationService})
      : _tripLocationService = tripLocationService ?? TripLocationService();

  static final LocationTrackingService _instance =
      LocationTrackingService._internal();

  /// Singleton — tracking must survive navigating away from TripDetailScreen
  /// (and the ViewModel that started it being disposed), so it can't be
  /// owned by a single screen's lifecycle. Pass a mock via
  /// [LocationTrackingService.forTesting] in tests instead of this getter.
  factory LocationTrackingService() => _instance;

  /// Test-only constructor for injecting a fake TripLocationService.
  @visibleForTesting
  factory LocationTrackingService.forTesting(TripLocationService tripLocationService) {
    return LocationTrackingService._internal(tripLocationService: tripLocationService);
  }

  final TripLocationService _tripLocationService;

  StreamSubscription<Position>? _subscription;
  String? _activeTripId;

  bool get isTracking => _subscription != null;
  String? get activeTripId => _activeTripId;

  /// Starts streaming GPS updates for [tripId]/[userId]. If already tracking
  /// a different trip, that stream is stopped first. Calling this again for
  /// the same tripId is a no-op.
  Future<void> start(String tripId, {required String userId}) async {
    if (_activeTripId == tripId && isTracking) return;

    await stop();

    final hasPermission = await _ensurePermission();
    if (!hasPermission) {
      throw Exception('Location permission not granted.');
    }

    _activeTripId = tripId;

    _subscription = Geolocator.getPositionStream(
      locationSettings: _buildLocationSettings(),
    ).listen(
      (position) {
        // Fire-and-forget: don't let a single failed upload kill the stream.
        // TODO: consider surfacing repeated failures (e.g. via a callback
        // or a status stream) once there's UI to show tracking health.
        _tripLocationService
            .saveLocation(
              tripId,
              userId: userId,
              latitude: position.latitude,
              longitude: position.longitude,
              timestamp: position.timestamp,
            )
            .catchError((_) {});
      },
      onError: (_) {
        // Stream itself failed (e.g. permission revoked mid-trip). Stop
        // cleanly rather than leaving a dead subscription around.
        stop();
      },
    );
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _activeTripId = null;
  }

  Future<bool> _ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  LocationSettings _buildLocationSettings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20, // meters between updates
        intervalDuration: const Duration(seconds: 15),
        // Required to keep receiving updates once the app is backgrounded —
        // Android kills background location access without a foreground
        // service + persistent notification.
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'RoamiO is tracking your trip',
          notificationText: 'Location sharing is active for your trip.',
          enableWakeLock: true,
        ),
      );
    }

    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    }

    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20,
    );
  }
}