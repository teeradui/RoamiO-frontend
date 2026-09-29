import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../config/auth_headers.dart';
import '../trip_friend_model.dart';

/// Raw data access for friends/friend requests.
/// Throws on any failure — callers (TripFriendService) decide how to handle it.
class TripFriendRepository {
  Future<TripFriendRequest> sendRequest(String receiverId) async {
    final uri = Uri.parse('${ApiConfig.friends}/sendRequest');
    final headers = await AuthHeaders.build();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'receiverId': receiverId}),
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
    final headers = await AuthHeaders.build();

    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load friend (${response.statusCode}): ${response.body}',
      );
    }

    return TripFriend.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<TripFriendRequest> getRequestById(String requestId) async {
    final uri = Uri.parse('${ApiConfig.friends}/request/$requestId');
    final headers = await AuthHeaders.build();

    final response = await http.get(uri, headers: headers);
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load friend request (${response.statusCode}): ${response.body}',
      );
    }

    return TripFriendRequest.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<TripFriend>> getAllFriends() async {
    final uri = Uri.parse('${ApiConfig.friends}/allFriends');
    final headers = await AuthHeaders.build();

    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load friends (${response.statusCode}): ${response.body}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => TripFriend.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<TripFriendRequest>> getAllRequests() async {
    final uri = Uri.parse('${ApiConfig.friends}/allRequests');
    final headers = await AuthHeaders.build();

    final response = await http.get(uri, headers: headers);

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
    final headers = await AuthHeaders.build();

    final response = await http.patch(
      uri,
      headers: headers,
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
    final headers = await AuthHeaders.build();

    final response = await http.patch(
      uri,
      headers: headers,
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

  Future<List<RecommendedFriend>> getRecommendedFriends({int limit = 10,}) async {
    final uri = Uri.parse('${ApiConfig.friends}/recommendations?limit=$limit');
    final headers = await AuthHeaders.build();

    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load recommended friends (${response.statusCode}): ${response.body}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => RecommendedFriend.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RecommendedFriend>> searchUsers(String query) async {
    final uri = Uri.parse('${ApiConfig.friends}/search').replace(
      queryParameters: {'q': query},
    );
    final headers = await AuthHeaders.build();

    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to search users (${response.statusCode}): ${response.body}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => RecommendedFriend.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}