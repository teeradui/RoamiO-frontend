import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../config/auth_headers.dart';
import '../trip_friend_model.dart';

/// Raw data access for friends/friend requests.
/// Throws on any failure — callers (TripFriendService) decide how to handle it.
class TripFriendRepository {
  Future<TripFriendRequest> sendRequest(String senderId, String receiverId) async {
    final uri = Uri.parse('${ApiConfig.friends}/sendRequest');

    // TODO: add soon — should include AuthHeaders once JWT auth exists.
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'senderId': senderId, 'receiverId': receiverId}),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        'Failed to send friend request (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    return TripFriendRequest.fromJson(decoded['request'] as Map<String, dynamic>);
  }

  Future<TripFriend> getFriendById(String friendId) async {
    final uri = Uri.parse('${ApiConfig.friends}/friend/$friendId');

    // TODO: add soon — should include AuthHeaders once JWT auth exists.
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load friend (${response.statusCode}): ${response.body}',
      );
    }

    return TripFriend.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<TripFriendRequest> getRequestById(String requestId) async {
    final uri = Uri.parse('${ApiConfig.friends}/request/$requestId');

    // TODO: add soon — should include AuthHeaders once JWT auth exists.
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load friend request (${response.statusCode}): ${response.body}',
      );
    }

    return TripFriendRequest.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<TripFriend>> getAllFriends(String userId) async {
    final uri = Uri.parse('${ApiConfig.friends}/allFriends?userId=$userId');

    // TODO: add soon — should include AuthHeaders once JWT auth exists.
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load friends (${response.statusCode}): ${response.body}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => TripFriend.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<TripFriendRequest>> getAllRequests(String userId) async {
    final uri = Uri.parse('${ApiConfig.friends}/allRequests?userId=$userId');

    // TODO: add soon — should include AuthHeaders once JWT auth exists.
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load friend requests (${response.statusCode}): ${response.body}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => TripFriendRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TripFriend> updateFriendStatus(String friendId, FriendStatus status) async {
    final uri = Uri.parse('${ApiConfig.friends}/friend/$friendId');

    // TODO: add soon — should include AuthHeaders once JWT auth exists.
    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': friendStatusToString(status)}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update friend status (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    return TripFriend.fromJson(decoded['updatedFriend'] as Map<String, dynamic>);
  }

  Future<TripFriendRequest> updateRequestStatus(String requestId, RequestStatus status) async {
    final uri = Uri.parse('${ApiConfig.friends}/request/$requestId');

    // TODO: add soon — should include AuthHeaders once JWT auth exists.
    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': requestStatusToString(status)}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update request status (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    return TripFriendRequest.fromJson(decoded['updatedRequest'] as Map<String, dynamic>);
  }
}