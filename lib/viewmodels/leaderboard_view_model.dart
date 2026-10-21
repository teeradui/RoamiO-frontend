import 'package:flutter/foundation.dart';
import 'package:roamio_frontend/models/services/trip_account_service.dart';

enum LeaderboardErrorType { system, network }

class LeaderboardUser {
  final String userId;
  final String name;
  final String username;
  final String? profileImageUrl;
  final int reliabilityScore;
  final String? title;

  const LeaderboardUser({
    required this.userId,
    required this.name,
    required this.username,
    this.profileImageUrl,
    required this.reliabilityScore,
    this.title,
  });
}

class LeaderboardViewModel extends ChangeNotifier {
  LeaderboardViewModel({TripAccountService? tripAccountService})
    : _tripAccountService = tripAccountService ?? TripAccountService();

  final TripAccountService _tripAccountService;

  LeaderboardErrorType? _errorType;
  List<LeaderboardUser> _users = [];

  String? get errorMessage {
    switch (_errorType) {
      case LeaderboardErrorType.system:
        return 'Unable to load leaderboard. Please try again.';
      case LeaderboardErrorType.network:
        return 'Request failed. Please check your connection.';
      case null:
        return null;
    }
  }

  static const List<String> _topTitles = [
    'Reliability Rockstar!',
    'Trust Superstar!',
    'Consistency Star!',
  ];

  List<LeaderboardUser> get users {
    final sortedUsers = List<LeaderboardUser>.from(_users);
    sortedUsers.sort(
      (a, b) => b.reliabilityScore.compareTo(a.reliabilityScore),
    );
    return List.unmodifiable(sortedUsers);
  }

  LeaderboardUser get topUser => users.first;

  List<LeaderboardUser> get topThree => users.take(3).toList();

  int getRank(String userId) {
    return users.indexWhere((user) => user.userId == userId) + 1;
  }

  Future<void> loadLeaderboard() async {
    _errorType = null;
    notifyListeners();

    try {
      final entries = await _tripAccountService.getLeaderboard(limit: 50);

      _users = entries.asMap().entries.map((entry) {
        final index = entry.key;
        final e = entry.value;

        return LeaderboardUser(
          userId: e.userId,
          name: '${e.firstName} ${e.lastName}'.trim(),
          username: '@${e.username}',
          profileImageUrl: e.profilePicture,
          reliabilityScore: e.reliabilityScore.round(),
          title: index < _topTitles.length ? _topTitles[index] : null,
        );
      }).toList();

      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('LOAD LEADERBOARD ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      final message = error.toString().toLowerCase();
      if (message.contains('socketexception') ||
          message.contains('connection refused') ||
          message.contains('failed host lookup') ||
          message.contains('network is unreachable') ||
          message.contains('timed out')) {
        _errorType = LeaderboardErrorType.network;
      } else {
        _errorType = LeaderboardErrorType.system;
      }

      notifyListeners();
    }
  }

  void setSystemError() {
    _errorType = LeaderboardErrorType.system;
    notifyListeners();
  }

  void setNetworkError() {
    _errorType = LeaderboardErrorType.network;
    notifyListeners();
  }

  void clearError() {
    _errorType = null;
    notifyListeners();
  }
}
