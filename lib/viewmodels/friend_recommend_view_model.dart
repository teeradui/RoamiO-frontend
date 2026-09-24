import 'package:flutter/foundation.dart';
import 'package:roamio_frontend/viewmodels/friend_list_error.dart';
import 'package:roamio_frontend/viewmodels/my_friends_view_model.dart';

enum FriendRequestStatus { none, pending, friends }

class FriendRecommendViewModel extends ChangeNotifier {
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

  final List<FriendItem> _recommendations = [
    // TODO: Replace mock recommendations with users
  // who previously participated in the same trips as the registered user.
    const FriendItem(
      userId: '4',
      name: 'Alice',
      username: '@alice',
      profileImageUrl: 'https://i.pinimg.com/736x/b9/7a/7c/b97a7cdd20f7b616d6b7cb6ae6f2c719.jpg',
      reliabilityScore: 285,
    ),
    const FriendItem(
      userId: '5',
      name: 'Max',
      username: '@max',
      profileImageUrl: 'https://i.pinimg.com/736x/77/f7/ba/77f7ba78996cfa4f927fe0ff7006d464.jpg',
      reliabilityScore: 240,
    ),
    const FriendItem(
      userId: '6',
      name: 'Charlie',
      username: '@charlie',
      profileImageUrl: 'https://i.pinimg.com/1200x/0b/fd/75/0bfd757069e6db2513a6dafbdbfdd7a7.jpg',
      reliabilityScore: 310,
    ),
  ];
// TODO: Replace mock current user ID with the registered user's
// actual user ID from authentication/backend.
  final String _currentUserId = '1';

  final Set<String> _friendIds = {'4'};

  final Set<String> _pendingRequestIds = {'5'};

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
    if (_friendIds.contains(userId)) {
      return FriendRequestStatus.friends;
    }

    if (_pendingRequestIds.contains(userId)) {
      return FriendRequestStatus.pending;
    }

    return FriendRequestStatus.none;
  }

  String? getRequestError(String userId) {
    return _requestErrorMessages[userId];
  }

  Future<void> loadRecommendations() async {
    _errorType = null;
    notifyListeners();

    try {
      // TODO: replace with backend service later
      await Future.delayed(const Duration(milliseconds: 300));

      // Keep current mock recommendations.
    } catch (e) {
      final message = e.toString().toLowerCase();

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

    // SRS-208
    if (_friendIds.contains(userId)) {
      return;
    }

    // SRS-209
    if (_pendingRequestIds.contains(userId)) {
      return;
    }

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      // SRS-207
      _pendingRequestIds.add(userId);

      notifyListeners();
    } catch (e) {
      // SRS-211
      _requestErrorMessages[userId] =
          'Unable to send friend request. Please try again.';
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
