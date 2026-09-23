import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:roamio_frontend/screens/profile/settings_screen.dart';
import 'package:roamio_frontend/viewmodels/story_trip_awards_view_model.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel() {
    loadProfileAwards(tripId: '1');
  }

  // Profile information
  String _name = 'Teerada Bun-in';
  String _username = 'teerada';

  // Trip statistics
  int _tripsCompleted = 12;
  int _joined = 12;
  int _attended = 12;

  // Reliability Credit Score
  int _reliabilityScore = 235;

  String get name => _name;
  String get username => _username;

  int get tripsCompleted => _tripsCompleted;
  int get joined => _joined;
  int get attended => _attended;

  int get reliabilityScore => _reliabilityScore;

  /// Attendance rate
  int get attendanceRate {
    if (_joined == 0) return 0;

    return ((_attended / _joined) * 100).round().clamp(0, 100);
  }

  String get reliabilityTitle {
    if (_reliabilityScore >= 300) {
      return 'Journey Legend';
    } else if (_reliabilityScore >= 270) {
      return 'Travel Master';
    } else if (_reliabilityScore >= 250) {
      return 'Road Warrior';
    } else if (_reliabilityScore >= 230) {
      return 'Reliable Explorer';
    } else if (_reliabilityScore >= 200) {
      return 'Happy Traveler';
    } else if (_reliabilityScore >= 170) {
      return 'Getting There';
    } else if (_reliabilityScore >= 150) {
      return 'Weekend Wanderer';
    } else if (_reliabilityScore >= 130) {
      return 'Trip Rookie';
    } else {
      return 'Trip Ghost';
    }
  }

  /// Score color
  bool get isReliable => _reliabilityScore >= 200;

  void setReliabilityScore(int score) {
    _reliabilityScore = score;
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
    _name = '';
    _username = '';
    _tripsCompleted = 0;
    _joined = 0;
    _attended = 0;
    _reliabilityScore = 0;
    _awards = [];

    notifyListeners();
  }

  void openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  List<StoryTripAward> _awards = [];

  List<StoryTripAward> get awards => _awards;

  bool get hasAwards => _awards.isNotEmpty;

  void setAwards(List<StoryTripAward> awards) {
    _awards = awards;
    notifyListeners();
  }

  Future<void> loadProfileAwards({required String tripId}) async {
    final awardsViewModel = StoryTripAwardsViewModel(tripId: tripId);

    await awardsViewModel.loadTripAwards();

    _awards = awardsViewModel.awards;

    notifyListeners();
  }

  void loadMockAwards() {
    _awards = [
      StoryTripAward(
        userId: '1',
        username: 'teerada',
        type: TripAwardType.earlyArrival,
        awardTitle: 'Early Bird',
        awardSubtitle: '',
        awardIcon: Icons.wb_sunny_rounded,
        isCurrentUser: true,
      ),
      StoryTripAward(
        userId: '1',
        username: 'teerada',
        type: TripAwardType.food,
        awardTitle: 'Foodie Supreme',
        awardSubtitle: '',
        awardIcon: Icons.ramen_dining_rounded,
        isCurrentUser: true,
      ),
      StoryTripAward(
        userId: '1',
        username: 'teerada',
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
