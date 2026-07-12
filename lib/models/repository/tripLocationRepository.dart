import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../config/auth_headers.dart';
import '../tripLocationModel.dart';

/// Raw data access for trip location tracking. Throws on any failure —
/// TripLocationService decides how to handle it.
///
/// No caching here on purpose: live member locations should always be fetched
/// fresh, unlike trips/members/invites which change less often.
class TripLocationRepository {
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
        'location_timestamp': timestamp?.toIso8601String(),
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