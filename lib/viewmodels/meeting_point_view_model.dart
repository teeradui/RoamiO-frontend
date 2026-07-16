import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roamio_frontend/models/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class MeetingPointViewModel extends ChangeNotifier {
  MeetingPointViewModel({
    required this.locationService,
  });

  final LocationService locationService;

  List<dynamic> placePredictions = [];

  LatLng selectedLocation = const LatLng(18.7883, 98.9853);
  String selectedAddress = "Chiang Mai";

  bool isLoading = false;

  Future<void> searchPlaces(String input) async {
    if (input.trim().isEmpty) {
      placePredictions = [];
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    placePredictions = await locationService.searchPlaces(input);

    isLoading = false;
    notifyListeners();
  }

  Future<void> selectPlace({
    required String placeId,
    required String description,
  }) async {
    final latLng = await locationService.getPlaceLatLng(placeId);

    if (latLng == null) return;

    selectedLocation = latLng;
    selectedAddress = description;
    placePredictions = [];

    notifyListeners();
  }

  Future<void> updateAddressFromLatLng(LatLng latLng) async {
    selectedLocation = latLng;
    selectedAddress = "Loading location...";
    placePredictions = [];

    notifyListeners();

    final address = await locationService.getAddressFromLatLng(latLng);

    selectedAddress = address ?? "Selected location";

    notifyListeners();
  }

  Map<String, dynamic> get confirmData {
    return {
      "name": selectedAddress,
      "lat": selectedLocation.latitude,
      "lng": selectedLocation.longitude,
    };
  }

  void clearPredictions() {
    placePredictions = [];
    notifyListeners();
  }

  Future<void> loadCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    selectedAddress = "Location service is disabled";
    notifyListeners();
    return;
  }

  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    selectedAddress = "Location permission denied";
    notifyListeners();
    return;
  }

  final position = await Geolocator.getCurrentPosition();

  final latLng = LatLng(
    position.latitude,
    position.longitude,
  );

  await updateAddressFromLatLng(latLng);
}
}