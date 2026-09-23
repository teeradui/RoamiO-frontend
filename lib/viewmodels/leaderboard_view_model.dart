import 'package:flutter/foundation.dart';

enum LeaderboardErrorType { system, network }

class LeaderboardUser {
  final String userId;
  final String name;
  final String username;
  final String profileImagePath;
  final int reliabilityScore;
  final String? title;

  const LeaderboardUser({
    required this.userId,
    required this.name,
    required this.username,
    required this.profileImagePath,
    required this.reliabilityScore,
    this.title,
  });
}

class LeaderboardViewModel extends ChangeNotifier {
  LeaderboardErrorType? _errorType;

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

  final List<LeaderboardUser> _users = [
    const LeaderboardUser(
      userId: '1',
      name: 'Teedy',
      username: '@teedy',
      profileImagePath: 'assets/images/default_profile.png',
      reliabilityScore: 267,
      title: 'Reliability Rockstar!',
    ),
    const LeaderboardUser(
      userId: '2',
      name: 'Cherry',
      username: '@cherry',
      profileImagePath: 'assets/images/default_profile.png',
      reliabilityScore: 253,
      title: 'Trust Superstar!',
    ),
    const LeaderboardUser(
      userId: '3',
      name: 'Luna',
      username: '@luna',
      profileImagePath: 'assets/images/default_profile.png',
      reliabilityScore: 248,
      title: 'Consistency Star!',
    ),
    const LeaderboardUser(
      userId: '4',
      name: 'Ashly',
      username: '@ashly',
      profileImagePath: 'assets/images/default_profile.png',
      reliabilityScore: 232,
    ),
    const LeaderboardUser(
      userId: '5',
      name: 'Selena',
      username: '@selena',
      profileImagePath: 'assets/images/default_profile.png',
      reliabilityScore: 189,
    ),
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

  // TODO: Replace mock leaderboard data with backend data.
  Future<void> loadLeaderboard() async {
    _errorType = null;
    notifyListeners();

    try {
      // TODO: Load leaderboard from backend later.
      await Future.delayed(const Duration(milliseconds: 300));
      // TODO: Load leaderboard from backend later.
      // Keep current mock leaderboard data.
      notifyListeners();
    } catch (e) {
      final message = e.toString().toLowerCase();

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
