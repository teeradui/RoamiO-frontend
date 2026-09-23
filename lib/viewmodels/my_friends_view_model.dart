import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:roamio_frontend/config/api_config.dart';
import 'package:roamio_frontend/config/auth_headers.dart';
import 'package:roamio_frontend/viewmodels/friend_list_error.dart';

class FriendItem {
  final String userId;
  final String name;
  final String username;
  final String? profileImageUrl;
  final int reliabilityScore;
  final DateTime? requestTime;

  const FriendItem({
    required this.userId,
    required this.name,
    required this.username,
    this.profileImageUrl,
    required this.reliabilityScore,
    this.requestTime,
  });
}

class MyFriendsViewModel extends ChangeNotifier {
  FriendListErrorType? _errorType;

  final List<FriendItem> _friends = [
    FriendItem(
      userId: '1',
      name: 'Mina',
      username: '@mina',
      profileImageUrl: null,
      reliabilityScore: 285,
    ),
    FriendItem(
      userId: '2',
      name: 'Jane',
      username: '@jane',
      profileImageUrl: null,
      reliabilityScore: 190,
    ),
    FriendItem(
      userId: '3',
      name: 'Mark',
      username: '@mark',
      profileImageUrl: null,
      reliabilityScore: 200,
    ),
  ];

  String? get errorMessage {
    switch (_errorType) {
      case FriendListErrorType.system:
        return 'Unable to load friends. Please try again.';

      case FriendListErrorType.network:
        return 'Request failed. Please check your connection.';

      case null:
        return null;
    }
  }

  List<FriendItem> get friends => List.unmodifiable(_friends);

  Future<void> loadFriends() async {
    _errorType = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/friends'),
        headers: await AuthHeaders.build(),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load friends (${response.statusCode})',
        );
      }

      final decoded = jsonDecode(response.body);

      final friendsJson = decoded is List
          ? decoded
          : (decoded['friends'] ?? decoded['data'] ?? const <dynamic>[]);

      if (friendsJson is! List) {
        throw const FormatException('Invalid friends response');
      }

      _friends
        ..clear()
        ..addAll(
          friendsJson
              .whereType<Map>()
              .map(
                (friend) => _friendFromJson(
                  Map<String, dynamic>.from(friend),
                ),
              ),
        );

      notifyListeners();
    } on SocketException {
      _errorType = FriendListErrorType.network;
      notifyListeners();
    } on http.ClientException {
      _errorType = FriendListErrorType.network;
      notifyListeners();
    } catch (_) {
      _errorType = FriendListErrorType.system;
      notifyListeners();
    }
  }

  FriendItem _friendFromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : json;

    final rawUsername = (user['username'] ?? '').toString();

    return FriendItem(
      userId: (
        user['userId'] ??
        user['id'] ??
        user['user_id'] ??
        ''
      ).toString(),
      name: (
        user['name'] ??
        user['fullName'] ??
        user['displayName'] ??
        rawUsername
      ).toString(),
      username: rawUsername.isEmpty || rawUsername.startsWith('@')
          ? rawUsername
          : '@$rawUsername',
      profileImageUrl: (
        user['profileImageUrl'] ??
        user['profile_image_url'] ??
        user['avatarUrl']
      )?.toString(),
      reliabilityScore: (
        (user['reliabilityScore'] ??
                user['reliability_score'] ??
                user['score']) as num?
      )?.toInt() ?? 0,
    );
  }

  void setSystemError() {
    _errorType = FriendListErrorType.system;
    notifyListeners();
  }

  void setNetworkError() {
    _errorType = FriendListErrorType.network;
    notifyListeners();
  }

  void clearError() {
    _errorType = null;
    notifyListeners();
  }
}
