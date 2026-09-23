import 'package:flutter/foundation.dart';
import 'package:roamio_frontend/viewmodels/story_trip_awards_view_model.dart';

class FriendProfileViewModel extends ChangeNotifier {
  final String userId;

  FriendProfileViewModel({
    required this.userId,
  });

  // Mock data
  String _name = 'Emma Watson';
  String _username = '@emma';
  String _profileImagePath =
      'assets/images/default_profile.png';

  int _tripsCompleted = 18;
  int _joined = 18;
  int _attended = 17;

  int _reliabilityScore = 265;

  List<StoryTripAward> _awards = [];

  String get name => _name;
  String get username => _username;
  String get profileImagePath => _profileImagePath;

  int get tripsCompleted => _tripsCompleted;
  int get joined => _joined;
  int get attended => _attended;
  int get reliabilityScore => _reliabilityScore;

  int get attendanceRate {
    if (_joined == 0) return 0;

    return ((_attended / _joined) * 100)
        .round()
        .clamp(0, 100);
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

  

  List<StoryTripAward> get awards => _awards;

  Future<void> loadProfile() async {
    // TODO: Replace mock data with backend API
  }

  Future<void> loadAwards() async {
    // TODO: Load friend's awards from backend
  }

  Future<void> loadScoreHistory() async {
    // TODO: Load friend's score history from backend
  }

  void setProfileData({
    required String name,
    required String username,
    required int tripsCompleted,
    required int joined,
    required int attended,
    required int reliabilityScore,
  }) {
    _name = name;
    _username = username;
    _tripsCompleted = tripsCompleted;
    _joined = joined;
    _attended = attended;
    _reliabilityScore = reliabilityScore;

    notifyListeners();
  }

  void setAwards(List<StoryTripAward> awards) {
    _awards = awards;
    notifyListeners();
  }
}