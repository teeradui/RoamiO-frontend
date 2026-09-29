import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:roamio_frontend/screens/profile/settings_screen.dart';
import 'package:roamio_frontend/screens/authentication/sign_in_screen.dart';
import 'package:roamio_frontend/viewmodels/story_trip_awards_view_model.dart';
import 'package:roamio_frontend/models/services/auth_service.dart';
import 'package:roamio_frontend/models/services/trip_account_service.dart';
import 'package:roamio_frontend/models/trip_account_model.dart';

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
  ProfileViewModel({TripAccountService? tripAccountService})
      : _tripAccountService = tripAccountService ?? TripAccountService() {
    _initialize();
  }

  final TripAccountService _tripAccountService;

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  bool isLoading = false;
  String? errorMessage;

  // Profile information
  ProfileUser _user = const ProfileUser(
    userId: '',
    name: '',
    username: '',
    profileImageUrl: null,
    reliabilityScore: 200,
  );

  ProfileUser get user => _user;

  String get name => _user.name;
  String get username => _user.username;
  String? get profileImageUrl => _user.profileImageUrl;
  int get reliabilityScore => _user.reliabilityScore;

  // Trip statistics
  int _tripsCompleted = 0;
  int _joined = 0;
  int _attended = 0;

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

  bool get isReliable => _user.reliabilityScore >= 200;

  // =========================================================
  // INITIAL LOAD
  // =========================================================

  Future<void> _initialize() async {
    final userId = await AuthService.instance.getCurrentUserId();

    if (userId == null) {
      errorMessage = 'Not signed in.';
      notifyListeners();
      return;
    }

    await loadProfile(userId);
    await loadTripStatistics(userId);
    await loadProfileAwards(userId);
  }

  Future<void> loadProfile(String userId) async {
    if (_isDisposed) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final account = await _tripAccountService.getAccountById(userId);

      if (_isDisposed) return;

      _user = ProfileUser(
        userId: account.userId,
        name: account.firstName.isNotEmpty
            ? '${account.firstName} ${account.lastName}'.trim()
            : account.username,
        username: '@${account.username}',
        profileImageUrl: account.profilePicture,
        reliabilityScore: account.reliabilityScore.round(),
      );
    } catch (error, stackTrace) {
      debugPrint('LOAD PROFILE ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (_isDisposed) return;
      errorMessage = 'Unable to load profile.';
    } finally {
      if (_isDisposed) return;
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTripStatistics(String userId) async {
    if (_isDisposed) return;

    try {
      final trips = await _tripAccountService.getAccountTrips(userId);

      if (_isDisposed) return;

      _joined = trips.length;

      _attended = trips
          .where((t) => t.attendance != ReliabilityAttendance.missing)
          .length;

      _tripsCompleted = trips
          .where((t) => t.tripStatus == TripStatus.completed)
          .length;

      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('LOAD TRIP STATISTICS ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      // Leave stats at 0 rather than surfacing a second error banner
      // alongside a possible profile-load error.
    }
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> logout(BuildContext context) async {
    await AuthService.instance.logout();

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

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()), // TODO: confirm actual sign-in screen widget
        (route) => false,
      );
    }
  }

  void openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  // =========================================================
  // AWARDS
  // =========================================================

  List<AccountAward> _awards = [];

  List<AccountAward> get awards => _awards;

  bool get hasAwards => _awards.isNotEmpty;

  Future<void> loadProfileAwards(String userId) async {
    if (_isDisposed) return;

    try {
      final fetchedAwards = await _tripAccountService.getAwardsByUserId(userId);

      if (_isDisposed) return;

      _awards = fetchedAwards;
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('LOAD PROFILE AWARDS ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      // Leave awards empty rather than surfacing another error banner.
    }
  }
}