import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static const String googleApiKey = "AIzaSyBty36QTsm3yDtQVyDrDF13wzOWR0aup70";

  final Geocoding geocoding = Geocoding();

  Future<List<Map<String, dynamic>>> getCountries() async {
    final res = await rootBundle.loadString(
      'packages/country_state_city_picker/lib/assets/country.json',
    );

    final List<dynamic> data = jsonDecode(res);

    return data.cast<Map<String, dynamic>>();
  }

  List<Map<String, dynamic>> getStatesByCountry(
    Map<String, dynamic>? country,
  ) {
    if (country == null) return [];

    final states = country['state'];

    if (states == null) return [];

    return List<Map<String, dynamic>>.from(states);
  }

  Future<List<dynamic>> searchPlaces(String input) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/autocomplete/json"
      "?input=${Uri.encodeComponent(input)}"
      "&key=$googleApiKey"
      "&language=en",
    );

    final response = await http.get(url);

    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);

    return data["predictions"] ?? [];
  }

  Future<LatLng?> getPlaceLatLng(String placeId) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/details/json"
      "?place_id=$placeId"
      "&key=$googleApiKey",
    );

    final response = await http.get(url);

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    final location = data["result"]?["geometry"]?["location"];

    if (location == null) return null;

    return LatLng(
      location["lat"],
      location["lng"],
    );
  }

  Future<String?> getAddressFromLatLng(LatLng latLng) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;

      final name = [
        place.name,
        place.street,
        place.subLocality,
        place.locality,
      ].where((e) => e != null && e.isNotEmpty).join(", ");

      return name.isNotEmpty ? name : null;
    } catch (_) {
      return null;
    }
  }
}