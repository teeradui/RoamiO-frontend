import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../config/auth_headers.dart';
import '../trip_member_model.dart';

/// Raw data access for trip members. Throws on any failure —
/// TripMemberService decides how to handle it.
class TripMemberRepository {
  final Map<String, List<TripMember>> _cache = {}; // keyed by tripId

  void _invalidate(String tripId) => _cache.remove(tripId);

  Future<List<TripMember>> findByTrip(String tripId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _cache.containsKey(tripId)) {
      return _cache[tripId]!;
    }

    final uri = Uri.parse(ApiConfig.tripMembers(tripId));
    final headers = await AuthHeaders.build();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to load members (${response.statusCode}): ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    final members = data.map((e) => TripMember.fromJson(e)).toList();
    _cache[tripId] = members;
    return members;
  }

  Future<TripMember> updateStatus(String tripId, String participantId, String memberStatus) async {
    final uri = Uri.parse('${ApiConfig.tripMembers(tripId)}/$participantId');
    final headers = await AuthHeaders.build();
    final response = await http.patch(
      uri,
      headers: headers,
      body: jsonEncode({'memberStatus': memberStatus}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update member status (${response.statusCode}): ${response.body}');
    }

    _invalidate(tripId);
    final body = jsonDecode(response.body);
    return TripMember.fromJson(body['member']);
  }

  Future<void> remove(String tripId, String participantId) async {
    final uri = Uri.parse('${ApiConfig.tripMembers(tripId)}/$participantId');
    final headers = await AuthHeaders.build();
    final response = await http.delete(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to remove member (${response.statusCode}): ${response.body}');
    }

    _invalidate(tripId);
  }
}