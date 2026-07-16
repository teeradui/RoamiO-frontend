import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../config/auth_headers.dart';
import '../trip_location_model.dart';

/// Raw data access for trip location tracking. Throws on any failure —
/// TripLocationService decides how to handle it.
///
/// No caching here on purpose: live member locations should always be fetched
/// fresh, unlike trips/members/invites which change less often.
class TripLocationRepository {
  Future<TripLocation> saveCurrentLocation(
    String tripId, {
    required String userId,
  }) async {
    final position = await _getCurrentPosition();
 
    return save(
      tripId,
      userId: userId,
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: position.timestamp,
    );
  }
 
  Future<Position> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }
 
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }
 
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission permanently denied. Enable it in device settings.',
      );
    }
 
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Future<TripLocation> save(
    String tripId, {
    required String userId,
    required double latitude,
    required double longitude,
    DateTime? timestamp,
  }) async {
    final uri = Uri.parse(ApiConfig.tripLocation(tripId));
    final headers = await AuthHeaders.build();
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'user_id': userId,
        'latitude': latitude,
        'longitude': longitude,
        'location_timestamp': timestamp?.toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to save location (${response.statusCode}): ${response.body}');
    }

    final body = jsonDecode(response.body);
    return TripLocation.fromJson(body['location']);
  }

  Future<List<LatestMemberLocation>> getLatest(String tripId) async {
    final uri = Uri.parse('${ApiConfig.tripLocation(tripId)}/latest');
    final headers = await AuthHeaders.build();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to load latest locations (${response.statusCode}): ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => LatestMemberLocation.fromJson(e)).toList();
  }
}