import 'package:flutter/foundation.dart';
import 'package:roamio_frontend/viewmodels/friend_list_error.dart';
import 'package:roamio_frontend/viewmodels/my_friends_view_model.dart';
import 'package:roamio_frontend/models/services/trip_friend_service.dart';
import 'package:roamio_frontend/models/services/auth_service.dart';
import 'package:roamio_frontend/models/trip_friend_model.dart';

enum FriendRequestStatus { none, pending, friends }

class FriendRecommendViewModel extends ChangeNotifier {
  FriendRecommendViewModel({TripFriendService? tripFriendService})
      : _tripFriendService = tripFriendService ?? TripFriendService();

  final TripFriendService _tripFriendService;

  FriendListErrorType? _errorType;

  String? get errorMessage {
    switch (_errorType) {
      case FriendListErrorType.system:
        return 'Unable to load friend list. Please try again.';
      case FriendListErrorType.network:
        return 'Request failed. Please check your connection.';
      case null:
        return null;
    }
  }

  List<FriendItem> _recommendations = [];
  String? _currentUserId;

  final Set<String> _friendIds = {};
  final Set<String> _pendingRequestIds = {};
  final Map<String, String> _requestErrorMessages = {};

  List<FriendItem> get recommendations => _recommendations
      .where(
        (user) =>
            user.userId != _currentUserId &&
            !_friendIds.contains(user.userId) &&
            !_pendingRequestIds.contains(user.userId),
      )
      .toList();

  FriendRequestStatus getRequestStatus(String userId) {
    if (_friendIds.contains(userId)) return FriendRequestStatus.friends;
    if (_pendingRequestIds.contains(userId)) return FriendRequestStatus.pending;
    return FriendRequestStatus.none;
  }

  String? getRequestError(String userId) => _requestErrorMessages[userId];

  Future<void> loadRecommendations() async {
    _errorType = null;
    notifyListeners();

    try {
      _currentUserId = await AuthService.instance.getCurrentUserId();

      final results = await Future.wait([
        _tripFriendService.getRecommendedFriends(),
        _tripFriendService.getAllFriends(),
        _tripFriendService.getAllRequests(),
      ]);

      final recommended = results[0] as List<RecommendedFriend>;
      final friends = results[1] as List<TripFriend>;
      final requests = results[2] as List<TripFriendRequest>;

      _friendIds
        ..clear()
        ..addAll(
          friends
              .where((f) => f.friendStatus == FriendStatus.friend)
              .map((f) => f.userId == _currentUserId ? f.friendUserId : f.userId),
        );

      _pendingRequestIds
        ..clear()
        ..addAll(
          requests
              .where((r) =>
                  r.senderId == _currentUserId &&
                  r.requestStatus == RequestStatus.undecided)
              .map((r) => r.receiverId),
        );

      _recommendations = recommended.map((r) {
        return FriendItem(
          userId: r.userId,
          name: '${r.firstName} ${r.lastName}'.trim(),
          username: '@${r.username}',
          profileImageUrl: r.profilePicture,
          reliabilityScore: 0, // WIP: recommendations don't include a score
        );
      }).toList();

      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('LOAD RECOMMENDATIONS ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      final message = error.toString().toLowerCase();
      if (message.contains('socketexception') ||
          message.contains('connection refused') ||
          message.contains('failed host lookup') ||
          message.contains('network is unreachable') ||
          message.contains('timed out')) {
        _errorType = FriendListErrorType.network;
      } else {
        _errorType = FriendListErrorType.system;
      }

      notifyListeners();
    }
  }

  Future<void> sendFriendRequest(String userId) async {
    _requestErrorMessages.remove(userId);
    notifyListeners();

    if (_friendIds.contains(userId)) return;
    if (_pendingRequestIds.contains(userId)) return;

    try {
      await _tripFriendService.sendRequest(userId);

      _pendingRequestIds.add(userId);
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('SEND FRIEND REQUEST ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      _requestErrorMessages[userId] = 'Unable to send friend request. Please try again.';
      notifyListeners();
    }
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