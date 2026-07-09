import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

class MapSectionViewModel extends ChangeNotifier {
  LatLng mapCenter = const LatLng(18.7883, 98.9853);

  final List<MemberMapLocation> members = [
    MemberMapLocation(
      id: "1",
      username: "Teedy",
      location: const LatLng(18.7883, 98.9853),
      profileImageUrl: null,
    ),
    MemberMapLocation(
      id: "2",
      username: "Cherry",
      location: const LatLng(18.7900, 98.9870),
      profileImageUrl: null,
    ),
    MemberMapLocation(
      id: "3",
      username: "Pang",
      location: const LatLng(18.7865, 98.9825),
      profileImageUrl: null,
    ),
  ];

  bool get hasMemberLocations => members.isNotEmpty;
}