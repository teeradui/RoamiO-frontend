import 'package:flutter/foundation.dart';
import 'package:roamio_frontend/models/services/trip_account_service.dart';
import 'package:roamio_frontend/models/trip_account_model.dart' hide TripStatus;
import 'package:roamio_frontend/viewmodels/trip_detail_view_model.dart' show TripStatus;
// ^ adjust the TripStatus import to whichever file is the correct source in your codebase,
// consistent with how you resolved the TripStatus collision in photo_section_view_model.dart

class FriendProfileViewModel extends ChangeNotifier {
  FriendProfileViewModel({
    required this.userId,
    TripAccountService? tripAccountService,
  }) : _tripAccountService = tripAccountService ?? TripAccountService();

  final String userId;
  final TripAccountService _tripAccountService;

  bool isLoading = false;
  String? errorMessage;

  String _name = '';
  String _username = '';
  String? _profileImageUrl;

  int _tripsCompleted = 0;
  int _joined = 0;
  int _attended = 0;
  int _reliabilityScore = 200;

  List<AccountAward> _awards = [];

  String get name => _name;
  String get username => _username;
  String? get profileImageUrl => _profileImageUrl;

  int get tripsCompleted => _tripsCompleted;
  int get joined => _joined;
  int get attended => _attended;
  int get reliabilityScore => _reliabilityScore;

  int get attendanceRate {
    if (_joined == 0) return 0;
    return ((_attended / _joined) * 100).round().clamp(0, 100);
  }

  String get reliabilityTitle {
    if (_reliabilityScore >= 300) return 'Journey Legend';
    if (_reliabilityScore >= 270) return 'Travel Master';
    if (_reliabilityScore >= 250) return 'Road Warrior';
    if (_reliabilityScore >= 230) return 'Reliable Explorer';
    if (_reliabilityScore >= 200) return 'Happy Traveler';
    if (_reliabilityScore >= 170) return 'Getting There';
    if (_reliabilityScore >= 150) return 'Weekend Wanderer';
    if (_reliabilityScore >= 130) return 'Trip Rookie';
    return 'Trip Ghost';
  }

  List<AccountAward> get awards => _awards;
  bool get hasAwards => _awards.isNotEmpty;

  Future<void> loadProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final account = await _tripAccountService.getAccountById(userId);

      _name = account.firstName.isNotEmpty
          ? '${account.firstName} ${account.lastName}'.trim()
          : account.username;
      _username = '@${account.username}';
      _profileImageUrl = account.profilePicture;
      _reliabilityScore = account.reliabilityScore.round();
    } catch (error, stackTrace) {
      debugPrint('LOAD FRIEND PROFILE ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      errorMessage = 'Unable to load profile.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadScoreHistory() async {
    try {
      final trips = await _tripAccountService.getAccountTrips(userId);

      _joined = trips.length;
      _attended = trips
          .where((t) => t.attendance != ReliabilityAttendance.missing)
          .length;
      _tripsCompleted = trips
          .where((t) => t.tripStatus == TripStatus.completed)
          .length;

      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('LOAD FRIEND SCORE HISTORY ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      // Leave stats at 0 rather than a second error banner.
    }
  }

  Future<void> loadAwards() async {
    try {
      _awards = await _tripAccountService.getAwardsByUserId(userId);
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('LOAD FRIEND AWARDS ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      // Leave awards empty rather than a second error banner.
    }
  }
}