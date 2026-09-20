import 'dart:async';

import 'package:flutter/material.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roamio_frontend/models/services/trip_location_service.dart';
import 'package:roamio_frontend/viewmodels/trip_detail_view_model.dart';
import 'package:roamio_frontend/models/services/trip_summary_service.dart';
import 'package:roamio_frontend/models/trip_summary_model.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:roamio_frontend/models/services/location_service.dart';

class MemberMapLocation {
  final String id;
  final String username;
  final String? profileImageUrl;
  final LatLng location;

  const MemberMapLocation({
    required this.id,
    required this.username,
    required this.location,
    this.profileImageUrl,
  });
}

class VisitedPlaceMapPoint {
  final String id;
  final String name;
  final String type;
  final String timeText;
  final LatLng location;

  const VisitedPlaceMapPoint({
    required this.id,
    required this.name,
    required this.type,
    required this.timeText,
    required this.location,
  });
}

class MapSectionViewModel extends ChangeNotifier {
  MapSectionViewModel({
    required this.tripId,
    required this.tripStatus,
    TripLocationService? tripLocationService,
    TripSummaryService? tripSummaryService,
  }) : _tripLocationService = tripLocationService ?? TripLocationService(),
       _tripSummaryService = tripSummaryService ?? TripSummaryService();

  final String tripId;
  final TripStatus tripStatus;
  final TripLocationService _tripLocationService;
  final TripSummaryService _tripSummaryService;
  final PolylinePoints _polylinePoints = PolylinePoints(
    apiKey: LocationService.googleApiKey,
  );

  static const LatLng _defaultMapCenter = LatLng(18.7883, 98.9853);

  LatLng mapCenter = _defaultMapCenter;

  List<MemberMapLocation> members = [];
  List<VisitedPlaceMapPoint> visitedPlaces = [];
  List<LatLng> routePoints = [];

  bool isLoading = false;
  bool isRefreshing = false;

  String? errorMessage;

  Timer? _refreshTimer;

  bool get isUpcoming => tripStatus == TripStatus.upcoming;

  bool get isActive => tripStatus == TripStatus.active;

  bool get isCompleted => tripStatus == TripStatus.completed;

  bool get hasMemberLocations => members.isNotEmpty;

  bool get hasVisitedPlaces => visitedPlaces.isNotEmpty;

  bool get hasRoute => routePoints.length >= 2;

  bool get hasMapData {
    return members.isNotEmpty ||
        visitedPlaces.isNotEmpty ||
        routePoints.isNotEmpty;
  }

  Set<Polyline> get routePolylines {
    if ((!isActive && !isCompleted) || !hasRoute) {
      return {};
    }

    return {
      Polyline(
        polylineId: const PolylineId('tracked_route'),
        points: routePoints,
        width: 5,
        color: AppColors.btnPrimary,
        geodesic: true,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };
  }

  Set<Marker> get visitedPlaceMarkers {
    return visitedPlaces.map((place) {
      return Marker(
        markerId: MarkerId('place_${place.id}'),
        position: place.location,
        infoWindow: InfoWindow(
          title: place.name,
          snippet: [
            if (place.type.isNotEmpty) place.type,
            if (place.timeText.isNotEmpty) place.timeText,
          ].join(' • '),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    }).toSet();
  }

  Future<void> loadMapData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (isUpcoming) {
        // Upcoming:
        // แสดงตำแหน่งล่าสุดของสมาชิก แต่ยังไม่มี route/history
        await _loadLatestMemberLocations();

        visitedPlaces = [];
        routePoints = [];
      } else if (isActive) {
        // Active:
        // แสดงตำแหน่งสมาชิกแบบ live + สถานที่ + route
        await _loadLatestMemberLocations();
        await _loadVisitedPlacesAndRoute();
      } else if (isCompleted) {
        // Completed:
        // ไม่เรียก latest location เพราะ backend อนุญาตเฉพาะ Active
        members = [];

        // ใช้ข้อมูลที่บันทึกไว้สำหรับ historical map
        await _loadVisitedPlacesAndRoute();
      }

      _updateMapCenter();

      _startLocationRefresh();
    } catch (error, stackTrace) {
      debugPrint('LOAD MAP DATA ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage = 'Unable to load trip map.';
      _clearMapData();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshMemberLocations() async {
    if (isCompleted || isRefreshing) return;

    isRefreshing = true;

    try {
      await _loadLatestMemberLocations();

      _updateMapCenter();

      errorMessage = null;
    } catch (error, stackTrace) {
      debugPrint('REFRESH MEMBER LOCATIONS ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> _loadLatestMemberLocations() async {
    final latestLocations = await _tripLocationService.getLatestLocations(
      tripId,
    );

    members = latestLocations
        .where((location) {
          return _isValidCoordinate(location.latitude, location.longitude);
        })
        .map((location) {
          return MemberMapLocation(
            id: location.userId.toString(),

            /*
             * ต้องให้ LatestMemberLocation มี username และ profileImageUrl
             * ซึ่งควรมาจาก backend ที่ JOIN ตาราง account
             */
            username: location.userName,
            profileImageUrl: location.profileImageUrl,

            location: LatLng(location.latitude, location.longitude),
          );
        })
        .toList();
  }

  Future<void> _loadVisitedPlacesAndRoute() async {
    final summary = await _tripSummaryService.getSummary(tripId);

    final validStops = summary.stops
        .where(
          (stop) =>
              stop.latitude != null &&
              stop.longitude != null &&
              stop.enteredAt != null &&
              _isValidCoordinate(stop.latitude!, stop.longitude!),
        )
        .toList();

    validStops.sort((a, b) => a.enteredAt!.compareTo(b.enteredAt!));

    // Create Google road-following route.
    await _loadGoogleRoute(validStops);

    // Create one map marker for each visited place.
    visitedPlaces = validStops.asMap().entries.map((entry) {
      final index = entry.key;
      final stop = entry.value;

      return VisitedPlaceMapPoint(
        id: stop.stopId,
        name: stop.locationName?.trim().isNotEmpty == true
            ? stop.locationName!
            : 'Stop ${index + 1}',
        type: stop.locationType ?? '',
        timeText: formatTime(stop.enteredAt!.toIso8601String()),
        location: LatLng(stop.latitude!, stop.longitude!),
      );
    }).toList();

    debugPrint('MAP HISTORY LOAD SUCCESS');
    debugPrint('Route points: ${routePoints.length}');
    debugPrint('Visited places: ${visitedPlaces.length}');

    for (final place in visitedPlaces) {
      debugPrint(
        'PLACE: ${place.name} '
        '${place.location}',
      );
    }
  }

  Future<List<LatLng>> _fetchRouteBetweenStops({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final response = await _polylinePoints.getRouteBetweenCoordinatesV2(
        request: RoutesApiRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          travelMode: TravelMode.driving,
          polylineQuality: PolylineQuality.highQuality,
        ),
      );

      if (response.routes.isEmpty) {
        debugPrint('GOOGLE ROUTE ERROR: ${response.errorMessage}');
        return [];
      }

      final points = response.routes.first.polylinePoints;

      if (points == null || points.isEmpty) {
        return [];
      }

      return points.map((point) {
        return LatLng(point.latitude, point.longitude);
      }).toList();
    } catch (error, stackTrace) {
      debugPrint('FETCH GOOGLE ROUTE ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      return [];
    }
  }

  Future<void> _loadGoogleRoute(List<TripStop> validStops) async {
    routePoints = [];

    if (validStops.length < 2) {
      return;
    }

    for (var i = 0; i < validStops.length - 1; i++) {
      final origin = LatLng(validStops[i].latitude!, validStops[i].longitude!);

      final destination = LatLng(
        validStops[i + 1].latitude!,
        validStops[i + 1].longitude!,
      );

      final segment = await _fetchRouteBetweenStops(
        origin: origin,
        destination: destination,
      );

      if (segment.isEmpty) {
        debugPrint(
          'NO GOOGLE ROUTE: '
          '$origin → $destination',
        );
        continue;
      }

      // Prevent duplicate point between two segments.
      if (routePoints.isNotEmpty && segment.isNotEmpty) {
        segment.removeAt(0);
      }

      routePoints.addAll(segment);
    }

    debugPrint(
      'GOOGLE MAP ROUTE POINTS: '
      '${routePoints.length}',
    );
  }

  void _startLocationRefresh() {
    _refreshTimer?.cancel();

    if (isCompleted) {
      return;
    }

    // Upcoming และ Active ต้องอัปเดตตำแหน่งสมาชิก
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      refreshMemberLocations();
    });
  }

  void _updateMapCenter() {
    if (isCompleted && routePoints.isNotEmpty) {
      mapCenter = routePoints.first;
      return;
    }

    if (members.isNotEmpty) {
      mapCenter = members.first.location;
      return;
    }

    if (visitedPlaces.isNotEmpty) {
      mapCenter = visitedPlaces.first.location;
      return;
    }

    if (routePoints.isNotEmpty) {
      mapCenter = routePoints.first;
    }
  }

  bool _isValidCoordinate(double latitude, double longitude) {
    if (latitude == 0 && longitude == 0) {
      return false;
    }

    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  String formatTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      return value;
    }

    final local = parsed.toLocal();
    final hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour >= 12 ? 'PM' : 'AM';

    return '$displayHour:$minute $period';
  }

  void _clearMapData() {
    members = [];
    visitedPlaces = [];
    routePoints = [];

    _refreshTimer?.cancel();
  }

  Future<void> retry() async {
    await loadMapData();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
