import 'package:flutter/foundation.dart';
import 'package:roamio_frontend/viewmodels/friend_list_error.dart';
import 'package:roamio_frontend/viewmodels/my_friends_view_model.dart';
import 'package:roamio_frontend/models/services/trip_friend_service.dart';
import 'package:roamio_frontend/models/services/trip_account_service.dart';
import 'package:roamio_frontend/models/services/auth_service.dart';
import 'package:roamio_frontend/models/trip_friend_model.dart';
import 'package:roamio_frontend/viewmodels/friend_display_item.dart';

class FriendRequestItem implements FriendDisplayItem {
  final String requestId;
  final String userId;
  @override
  final String name;
  @override
  final String username;
  @override
  final String? profileImageUrl;
  @override
  final int reliabilityScore;
  final DateTime? requestTime;

  const FriendRequestItem({
    required this.requestId,
    required this.userId,
    required this.name,
    required this.username,
    this.profileImageUrl,
    required this.reliabilityScore,
    this.requestTime,
  });
}

class FriendRequestViewModel extends ChangeNotifier {
  FriendRequestViewModel({
    TripFriendService? tripFriendService,
    TripAccountService? tripAccountService,
  }) : _tripFriendService = tripFriendService ?? TripFriendService(),
      _tripAccountService = tripAccountService ?? TripAccountService();

  final TripFriendService _tripFriendService;
  final TripAccountService _tripAccountService;

  FriendListErrorType? _errorType;

  FriendListErrorType? _responseErrorType;

  List<FriendRequestItem> _requests = [];

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

  List<FriendRequestItem> get requests => List.unmodifiable(_requests);

  Future<void> loadRequests() async {
    _errorType = null;
    notifyListeners();

    try {
      final currentUserId = await AuthService.instance.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('Not signed in');
      }

      final fetchedRequests = await _tripFriendService.getAllRequests();

      // Only show pending/undecided requests.
      final pendingRequests = fetchedRequests
        .where((request) =>
            request.requestStatus == RequestStatus.undecided)
        .toList();

      // For an incoming request, the other user is the sender.
      final otherUserIds = pendingRequests
        .map((request) => request.senderId)
        .toSet()
        .toList();

      final accountResults = await Future.wait(
        otherUserIds.map((userId) async {
          try {
            return await _tripAccountService.getAccountById(userId); 
          } catch (error) {
            debugPrint('LOAD REQUEST ACCOUNT ERROR ($userId): $error');
            return null;
          }
        }),
      );

      final accountsByUserId = <String, dynamic>{};

        for (var i = 0; i < otherUserIds.length; i++) {
          final account = accountResults[i];

          if (account != null) {
            accountsByUserId[otherUserIds[i]] = account;
          }
        }

        _requests = pendingRequests.map((request) {
          final otherUserId = request.senderId;
          final account = accountsByUserId[otherUserId];

          return FriendRequestItem(
            requestId: request.requestId,
            userId: request.senderId,
            name: account != null
                ? '${account.firstName} ${account.lastName}'.trim()
                : 'Unknown User',
            username: account != null
                ? '@${account.username}'
                : '',
            profileImageUrl: account?.profilePicture,
            reliabilityScore: account?.reliabilityScore.round() ?? 0,
            requestTime: null,
          );
        }).toList();

        notifyListeners();
      } catch (error, stackTrace) {
        debugPrint('LOAD REQUESTS ERROR: $error');
        debugPrintStack(stackTrace: stackTrace);

        final message = error.toString().toLowerCase();

        if (message.contains('socketexception') ||
            message.contains('connection refused') ||
            message.contains('network is unreachable') ||
            message.contains('failed host lookup') ||
            message.contains('timed out')) {
          _errorType = FriendListErrorType.network;
        } else {
          _errorType = FriendListErrorType.system;
        }

        notifyListeners();
      }
    }

  Future<void> acceptRequest(String requestId) async {
    _responseErrorType = null;
    notifyListeners();

    try {
      await _tripFriendService.updateRequestStatus(
        requestId,
        RequestStatus.accepted,
      );

      _requests.removeWhere(
        (request) => request.requestId == requestId,
      );

      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('ACCEPT REQUEST ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      final message = error.toString().toLowerCase();

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

  Future<void> declineRequest(String requestId) async {
    _responseErrorType = null;
    notifyListeners();

    try {
      await _tripFriendService.updateRequestStatus(
        requestId,
        RequestStatus.denied,
      );

      _requests.removeWhere(
        (request) => request.requestId == requestId,
      );

      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('DECLINE REQUEST ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      final message = error.toString().toLowerCase();

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