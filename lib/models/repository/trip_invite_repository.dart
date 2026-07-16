import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../config/auth_headers.dart';
import '../trip_invite_model.dart';

/// Raw data access for trip invites. Throws on any failure —
/// TripInviteService decides how to handle it.
class TripInviteRepository {
  final Map<String, List<TripInvite>> _cache = {}; // keyed by tripId

  void _invalidate(String tripId) => _cache.remove(tripId);

  Future<List<TripInvite>> findByTrip(String tripId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _cache.containsKey(tripId)) {
      return _cache[tripId]!;
    }

    final uri = Uri.parse(ApiConfig.tripInvites(tripId));
    final headers = await AuthHeaders.build();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to load invites (${response.statusCode}): ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    final invites = data.map((e) => TripInvite.fromJson(e)).toList();
    _cache[tripId] = invites;
    return invites;
  }

  Future<TripInvite> sendInvite(String tripId, String userId) async {
    final uri = Uri.parse(ApiConfig.tripInvites(tripId));
    final headers = await AuthHeaders.build();
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to send invite (${response.statusCode}): ${response.body}');
    }

    _invalidate(tripId);
    final body = jsonDecode(response.body);
    return TripInvite.fromJson(body['invite']);
  }

  Future<TripInvite> respondToInvite(String tripId, String tripInviteId, InviteStatus status) async {
    final uri = Uri.parse('${ApiConfig.tripInvites(tripId)}/$tripInviteId');
    final headers = await AuthHeaders.build();
    final response = await http.patch(
      uri,
      headers: headers,
      body: jsonEncode({'inviteStatus': inviteStatusToString(status)}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to respond to invite (${response.statusCode}): ${response.body}');
    }

    _invalidate(tripId);
    final body = jsonDecode(response.body);
    return TripInvite.fromJson(body['invite']);
  }
}