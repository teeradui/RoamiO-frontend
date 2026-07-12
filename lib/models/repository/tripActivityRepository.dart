import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../config/auth_headers.dart'; 
import '../tripActivityModel.dart';

/// Raw data access for trip activity timeline. Throws on any failure —
/// TripActivityService decides how to handle it.
class TripActivityRepository {
  final Map<String, List<TripActivity>> _cache = {}; // keyed by tripId

  Future<List<TripActivity>> findTimelineByTrip(String tripId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _cache.containsKey(tripId)) {
      return _cache[tripId]!;
    }

    final uri = Uri.parse('${ApiConfig.tripActivities(tripId)}/timeline');
    final headers = await AuthHeaders.build();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to load activity timeline (${response.statusCode}): ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    final activities = data.map((e) => TripActivity.fromJson(e)).toList();
    _cache[tripId] = activities;
    return activities;
  }
}