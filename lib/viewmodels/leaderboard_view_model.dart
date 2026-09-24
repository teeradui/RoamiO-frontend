import 'package:flutter/foundation.dart';

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
      profileImageUrl:
          'https://i.pinimg.com/736x/8e/d3/49/8ed349e7e3e46319c775edf070887e13.jpg',
      reliabilityScore: 367,
      title: 'Reliability Rockstar!',
    ),
    const LeaderboardUser(
      userId: '2',
      name: 'Jane',
      username: '@jane',
      profileImageUrl:
          'https://i.pinimg.com/736x/a2/cd/d7/a2cdd73dc8ffd68ea2a6faa703431d28.jpg',
      reliabilityScore: 190,
      title: 'Trust Superstar!',
    ),
    const LeaderboardUser(
      userId: '3',
      name: 'Mark',
      username: '@mark',
      profileImageUrl:
          'https://i.pinimg.com/1200x/93/95/ea/9395ea5873de39c9b1f154680e8e10dc.jpg',
      reliabilityScore: 200,
      title: 'Consistency Star!',
    ),
    const LeaderboardUser(
      userId: '4',
      name: 'Alice',
      username: '@alice',
      profileImageUrl:
          'https://i.pinimg.com/736x/b9/7a/7c/b97a7cdd20f7b616d6b7cb6ae6f2c719.jpg',
      reliabilityScore: 285,
    ),
    const LeaderboardUser(
      userId: '5',
      name: 'Mina',
      username: '@mina',
      profileImageUrl:
          'https://i.pinimg.com/736x/09/9b/f0/099bf067f08cbc40e4d7365815af7731.jpg',
      reliabilityScore: 245,
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
