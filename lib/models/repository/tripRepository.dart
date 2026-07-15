import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../config/auth_headers.dart';
import '../tripModel.dart';

/// Raw data access for trips: HTTP calls + a small in-memory cache.
/// Throws on any failure — callers (TripService) decide how to handle it.
class TripRepository {
  // Cache keyed by status string ('Upcoming' | 'Active' | 'Completed').
  final Map<String, List<Trip>> _statusCache = {};
  final Map<String, Trip> _tripCache = {};
  void _invalidateCache() => _statusCache.clear();

  Future<Trip> insert(Trip trip, File? image) async {
    final uri = Uri.parse(ApiConfig.trips);
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(await AuthHeaders.build(isJson: false));

    trip.toJson().forEach((key, value) {
      if (value != null) request.fields[key] = value.toString();
    });

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create trip (${response.statusCode}): ${response.body}');
    }

    _invalidateCache();
    return Trip.fromJson(jsonDecode(response.body));
  }

  Future<List<Trip>> findByStatus(String status, {bool forceRefresh = false}) async {
    if (!forceRefresh && _statusCache.containsKey(status)) {
      return _statusCache[status]!;
    }

    final uri = Uri.parse('${ApiConfig.trips}/status/${status.toLowerCase()}');
    final headers = await AuthHeaders.build();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to load $status trips (${response.statusCode}): ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    final trips = data.map((e) => Trip.fromJson(e)).toList();
    _statusCache[status] = trips;
    return trips;
  }

   Future<Trip> findById(String tripId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _tripCache.containsKey(tripId)) {
      return _tripCache[tripId]!;
    }
 
    final uri = Uri.parse('${ApiConfig.trips}/$tripId');
    final headers = await AuthHeaders.build();
    final response = await http.get(uri, headers: headers);
 
    if (response.statusCode != 200) {
      throw Exception('Failed to load trip (${response.statusCode}): ${response.body}');
    }
 
    final trip = Trip.fromJson(jsonDecode(response.body));
    _tripCache[tripId] = trip;
    return trip;
  }


  Future<Trip> update(String tripId, Map<String, dynamic> fields, {File? image}) async {
    final uri = Uri.parse('${ApiConfig.trips}/$tripId');
    final request = http.MultipartRequest('PATCH', uri);
    request.headers.addAll(await AuthHeaders.build(isJson: false));

    fields.forEach((key, value) {
      if (value != null) request.fields[key] = value.toString();
    });

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception('Failed to update trip (${response.statusCode}): ${response.body}');
    }

    _invalidateCache();
    return Trip.fromJson(jsonDecode(response.body));
  }

  Future<Trip> updateStatus(String tripId, TripStatus status) async {
    final uri = Uri.parse('${ApiConfig.trips}/$tripId/status');
    final headers = await AuthHeaders.build();
    final response = await http.patch(
      uri,
      headers: headers,
      body: jsonEncode({'status': tripStatusToString(status)}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update trip status (${response.statusCode}): ${response.body}');
    }

    _invalidateCache();
    return Trip.fromJson(jsonDecode(response.body));
  }

  Future<void> delete(String tripId) async {
    final uri = Uri.parse('${ApiConfig.trips}/$tripId');
    final headers = await AuthHeaders.build();
    final response = await http.delete(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete trip (${response.statusCode}): ${response.body}');
    }

    _invalidateCache();
  }
}