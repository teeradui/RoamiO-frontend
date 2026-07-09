import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum TripMapStatus {
  upcoming,
  active,
  completed,
}

class MemberMapLocation {
  final String id;
  final String username;
  final String? profileImageUrl;
  final LatLng location;

  MemberMapLocation({
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

  VisitedPlaceMapPoint({
    required this.id,
    required this.name,
    required this.type,
    required this.timeText,
    required this.location,
  });
}

class MapSectionViewModel extends ChangeNotifier {
  TripMapStatus tripStatus = TripMapStatus.active;

  LatLng mapCenter = const LatLng(18.7883, 98.9853);

  final List<MemberMapLocation> members = [
    MemberMapLocation(
      id: "member_1",
      username: "Teedy",
      location: const LatLng(18.7883, 98.9853),
    ),
    MemberMapLocation(
      id: "member_2",
      username: "Cherry",
      location: const LatLng(18.7900, 98.9870),
    ),
    MemberMapLocation(
      id: "member_3",
      username: "Pang",
      location: const LatLng(18.7865, 98.9825),
    ),
  ];

  /// เอาข้อมูลชุดเดียวกับ Places Visited ใน Overview มาใช้
  final List<VisitedPlaceMapPoint> visitedPlaces = [
    VisitedPlaceMapPoint(
      id: "place_1",
      name: "Chiang Mai University",
      type: "University",
      timeText: "09:30 AM",
      location: const LatLng(18.7883, 98.9853),
    ),
    VisitedPlaceMapPoint(
      id: "place_2",
      name: "One Nimman",
      type: "Shopping Area",
      timeText: "12:45 PM",
      location: const LatLng(18.8004, 98.9679),
    ),
    VisitedPlaceMapPoint(
      id: "place_3",
      name: "Tha Phae Gate",
      type: "Landmark",
      timeText: "04:10 PM",
      location: const LatLng(18.7877, 98.9931),
    ),
  ];

  bool get isActive => tripStatus == TripMapStatus.active;

  bool get hasMemberLocations => members.isNotEmpty;

  bool get hasVisitedPlaces => visitedPlaces.isNotEmpty;

  Set<Polyline> get routePolylines {
    if (!isActive || visitedPlaces.length < 2) return {};

    return {
      Polyline(
        polylineId: const PolylineId("visited_route"),
        points: visitedPlaces.map((place) => place.location).toList(),
        color: const Color(0xFFF7630D),
        width: 5,
      ),
    };
  }

  Future<void> loadMapData() async {
    // TODO: call backend later
    // members = response.members;
    // visitedPlaces = response.visitedPlaces;
    // tripStatus = response.status;
    notifyListeners();
  }
}