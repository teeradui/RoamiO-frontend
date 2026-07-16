import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roamio_frontend/models/services/trip_location_service.dart';
import 'package:roamio_frontend/viewmodels/trip_detail_view_model.dart';

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
  }) : _tripLocationService =
            tripLocationService ?? TripLocationService();

  final String tripId;
  final TripStatus tripStatus;
  final TripLocationService _tripLocationService;

  LatLng mapCenter = const LatLng(18.7883, 98.9853);

  List<MemberMapLocation> members = [];
  List<VisitedPlaceMapPoint> visitedPlaces = [];
  List<LatLng> routePoints = [];

  bool isLoading = false;
  bool isRefreshing = false;

  String? errorMessage;

  Timer? _refreshTimer;

  bool get isUpcoming => tripStatus == TripStatus.upcoming;

  bool get isActive => tripStatus == TripStatus.active;

  bool get hasMemberLocations => members.isNotEmpty;

  bool get hasVisitedPlaces => visitedPlaces.isNotEmpty;

  bool get hasRoute => routePoints.length >= 2;

  bool get hasMapData {
    return members.isNotEmpty ||
        visitedPlaces.isNotEmpty ||
        routePoints.isNotEmpty;
  }

  Set<Polyline> get routePolylines {
    // เส้นทางจะแสดงเฉพาะตอนทริป Active
    if (!isActive || !hasRoute) {
      return {};
    }

    return {
      Polyline(
        polylineId: const PolylineId('tracked_route'),
        points: routePoints,
        color: const Color(0xFFF7630D),
        width: 5,
        geodesic: true,
      ),
    };
  }

  Future<void> loadMapData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Upcoming และ Active แสดงตำแหน่งล่าสุดของสมาชิกเหมือนกัน
      await _loadLatestMemberLocations();

      if (isActive) {
        // Active เท่านั้นที่มีสถานที่ที่ไปมาและเส้นทาง
        await _loadVisitedPlacesAndRoute();
      } else {
        // Upcoming ไม่แสดงสถานที่และเส้นทาง
        visitedPlaces = [];
        routePoints = [];
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
    if (isRefreshing) return;

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
    final latestLocations =
        await _tripLocationService.getLatestLocations(tripId);

    members = latestLocations
        .where((location) {
          return _isValidCoordinate(
            location.latitude,
            location.longitude,
          );
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

            location: LatLng(
              location.latitude,
              location.longitude,
            ),
          );
        })
        .toList();
  }

  Future<void> _loadVisitedPlacesAndRoute() async {
    /*
     * ตรงนี้ต้องเรียก Service ที่ดึง:
     * 1. สถานที่ที่ไปมา
     * 2. พิกัดเส้นทางทั้งหมดระหว่าง tracking
     *
     * ตัวอย่าง:
     *
     * final result = await _tripRouteService.getTripRoute(tripId);
     *
     * visitedPlaces = result.visitedPlaces.map((place) {
     *   return VisitedPlaceMapPoint(
     *     id: place.id,
     *     name: place.name,
     *     type: place.type,
     *     timeText: _formatTime(place.arrivalTime),
     *     location: LatLng(
     *       place.latitude,
     *       place.longitude,
     *     ),
     *   );
     * }).toList();
     *
     * routePoints = result.routePoints.map((point) {
     *   return LatLng(
     *     point.latitude,
     *     point.longitude,
     *   );
     * }).toList();
     */

    // ยังไม่ใส่ mock data
    visitedPlaces = [];
    routePoints = [];
  }

  void _startLocationRefresh() {
    _refreshTimer?.cancel();

    // Upcoming และ Active ต้องอัปเดตตำแหน่งสมาชิก
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) {
        refreshMemberLocations();
      },
    );
  }

  void _updateMapCenter() {
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

  bool _isValidCoordinate(
    double latitude,
    double longitude,
  ) {
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