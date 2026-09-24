import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:roamio_frontend/screens/profile/settings_screen.dart';
import 'package:roamio_frontend/viewmodels/story_trip_awards_view_model.dart';

class ProfileUser {
  final String userId;
  final String name;
  final String username;
  final String? profileImageUrl;
  final int reliabilityScore;

  const ProfileUser({
    required this.userId,
    required this.name,
    required this.username,
    this.profileImageUrl,
    required this.reliabilityScore,
  });
}

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel() {
    loadProfileAwards(tripId: '1');
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // Profile information
  ProfileUser _user = const ProfileUser(
    userId: '1',
    name: 'Tiana',
    username: '@tiana',
    profileImageUrl:
        'https://i.pinimg.com/736x/8e/d3/49/8ed349e7e3e46319c775edf070887e13.jpg',
    reliabilityScore: 367,
  );

  ProfileUser get user => _user;

  String get name => _user.name;
  String get username => _user.username;
  String? get profileImageUrl => _user.profileImageUrl;
  int get reliabilityScore => _user.reliabilityScore;

  // Trip statistics
  int _tripsCompleted = 12;
  int _joined = 12;
  int _attended = 12;

  int get tripsCompleted => _tripsCompleted;
  int get joined => _joined;
  int get attended => _attended;

  // Attendance rate
  int get attendanceRate {
    if (_joined == 0) return 0;

    return ((_attended / _joined) * 100).round().clamp(0, 100);
  }

  // Reliability title
  String get reliabilityTitle {
    final score = _user.reliabilityScore;

    if (score >= 300) {
      return 'Journey Legend';
    } else if (score >= 270) {
      return 'Travel Master';
    } else if (score >= 250) {
      return 'Road Warrior';
    } else if (score >= 230) {
      return 'Reliable Explorer';
    } else if (score >= 200) {
      return 'Happy Traveler';
    } else if (score >= 170) {
      return 'Getting There';
    } else if (score >= 150) {
      return 'Weekend Wanderer';
    } else if (score >= 130) {
      return 'Trip Rookie';
    } else {
      return 'Trip Ghost';
    }
  }

  // Score color
  bool get isReliable => _user.reliabilityScore >= 200;

  void setReliabilityScore(int score) {
    _user = ProfileUser(
      userId: _user.userId,
      name: _user.name,
      username: _user.username,
      profileImageUrl: _user.profileImageUrl,
      reliabilityScore: score,
    );

    notifyListeners();
  }

  void setTripStatistics({
    required int tripsCompleted,
    required int joined,
    required int attended,
  }) {
    _tripsCompleted = tripsCompleted;
    _joined = joined;
    _attended = attended;

    notifyListeners();
  }

  Future<void> logout() async {
    _user = const ProfileUser(
      userId: '',
      name: '',
      username: '',
      profileImageUrl: null,
      reliabilityScore: 0,
    );

    _tripsCompleted = 0;
    _joined = 0;
    _attended = 0;
    _awards = [];

    notifyListeners();
  }

  void openSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  // Awards
  List<StoryTripAward> _awards = [];

  List<StoryTripAward> get awards => _awards;

  bool get hasAwards => _awards.isNotEmpty;

  void setAwards(List<StoryTripAward> awards) {
    _awards = awards;
    notifyListeners();
  }

  Future<void> loadProfileAwards({
    required String tripId,
  }) async {
    if (_isDisposed) return;

    final awardsViewModel = StoryTripAwardsViewModel(
      tripId: tripId,
    );

    await awardsViewModel.loadTripAwards();

    if (_isDisposed) return;

    _awards = awardsViewModel.awards;
    notifyListeners();
  }

  void loadMockAwards() {
    _awards = [
      StoryTripAward(
        userId: '1',
        username: '@tiana',
        type: TripAwardType.earlyArrival,
        awardTitle: 'Early Bird',
        awardSubtitle: '',
        awardIcon: Icons.wb_sunny_rounded,
        isCurrentUser: true,
      ),
      StoryTripAward(
        userId: '1',
        username: '@tiana',
        type: TripAwardType.food,
        awardTitle: 'Foodie Supreme',
        awardSubtitle: '',
        awardIcon: Icons.ramen_dining_rounded,
        isCurrentUser: true,
      ),
      StoryTripAward(
        userId: '1',
        username: '@tiana',
        type: TripAwardType.sightseeing,
        awardTitle: 'Explorer Mode',
        awardSubtitle: '',
        awardIcon: Icons.explore_rounded,
        isCurrentUser: true,
      ),
    ];

    notifyListeners();
  }
}