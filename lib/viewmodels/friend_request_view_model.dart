import 'package:flutter/foundation.dart';
import 'package:roamio_frontend/viewmodels/friend_list_error.dart';
import 'package:roamio_frontend/viewmodels/my_friends_view_model.dart';

class FriendRequestViewModel extends ChangeNotifier {
  FriendListErrorType? _errorType;

  FriendListErrorType? _responseErrorType;

  final List<FriendItem> _requests = [
    FriendItem(
      userId: '7',
      name: 'Emma',
      username: '@emma',
      profileImageUrl: null,
      reliabilityScore: 275,
      requestTime: DateTime.now(),
    ),
    FriendItem(
      userId: '8',
      name: 'James',
      username: '@james',
      profileImageUrl: null,
      reliabilityScore: 240,
      requestTime: DateTime.now().subtract(
        const Duration(minutes: 1),
      ),
    ),
    FriendItem(
      userId: '9',
      name: 'Sophie',
      username: '@sophie',
      profileImageUrl: null,
      reliabilityScore: 290,
      requestTime: DateTime.now().subtract(
        const Duration(days: 2),
      ),
    ),
  ];

  String? get errorMessage {
    switch (_errorType) {
      case FriendListErrorType.system:
        return 'Unable to load friend requests. Please try again.';

      case FriendListErrorType.network:
        return 'Request failed. Please check your connection.';

      case null:
        return null;
    }
  }

  String? get responseErrorMessage {
    switch (_responseErrorType) {
      case FriendListErrorType.system:
        return 'Unable to respond to friend request. Please try again.';

      case FriendListErrorType.network:
        return 'Request failed. Please check your connection.';

      case null:
        return null;
    }
  }

  List<FriendItem> get requests => List.unmodifiable(_requests);

  Future<void> loadRequests() async {
    _errorType = null;
    notifyListeners();

    try {
      // TODO: replace with backend service later
      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      // Keep current mock requests.
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

  Future<void> acceptRequest(String userId) async {
    _responseErrorType = null;
    notifyListeners();

    try {
      // TODO: Send accept friend request to backend
      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      _requests.removeWhere(
        (request) => request.userId == userId,
      );

      notifyListeners();
    } catch (e) {
      final message = e.toString().toLowerCase();

      if (message.contains('socketexception') ||
          message.contains('connection refused') ||
          message.contains('failed host lookup') ||
          message.contains('network is unreachable') ||
          message.contains('timed out')) {
        _responseErrorType = FriendListErrorType.network;
      } else {
        _responseErrorType = FriendListErrorType.system;
      }

      notifyListeners();
    }
  }

  Future<void> declineRequest(String userId) async {
    _responseErrorType = null;
    notifyListeners();

    try {
      // TODO: Send decline friend request to backend
      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      _requests.removeWhere(
        (request) => request.userId == userId,
      );

      notifyListeners();
    } catch (e) {
      final message = e.toString().toLowerCase();

      if (message.contains('socketexception') ||
          message.contains('connection refused') ||
          message.contains('failed host lookup') ||
          message.contains('network is unreachable') ||
          message.contains('timed out')) {
        _responseErrorType = FriendListErrorType.network;
      } else {
        _responseErrorType = FriendListErrorType.system;
      }

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

  void setResponseSystemError() {
    _responseErrorType = FriendListErrorType.system;
    notifyListeners();
  }

  void setResponseNetworkError() {
    _responseErrorType = FriendListErrorType.network;
    notifyListeners();
  }

  void clearError() {
    _errorType = null;
    _responseErrorType = null;
    notifyListeners();
  }
}