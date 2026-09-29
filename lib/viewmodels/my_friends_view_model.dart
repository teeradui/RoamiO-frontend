import 'package:flutter/foundation.dart';
import 'package:roamio_frontend/viewmodels/friend_list_error.dart';
import 'package:roamio_frontend/models/services/trip_friend_service.dart';
import 'package:roamio_frontend/models/services/trip_account_service.dart';
import 'package:roamio_frontend/models/services/auth_service.dart';
import 'package:roamio_frontend/models/trip_friend_model.dart';
import 'package:roamio_frontend/viewmodels/friend_display_item.dart';

class FriendItem implements FriendDisplayItem {
  @override
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

  const FriendItem({
    required this.userId,
    required this.name,
    required this.username,
    this.profileImageUrl,
    required this.reliabilityScore,
    this.requestTime,
  });
}

class MyFriendsViewModel extends ChangeNotifier {
  MyFriendsViewModel({
    TripFriendService? tripFriendService,
    TripAccountService? tripAccountService,
  })  : _tripFriendService = tripFriendService ?? TripFriendService(),
        _tripAccountService = tripAccountService ?? TripAccountService();

  final TripFriendService _tripFriendService;
  final TripAccountService _tripAccountService;

  FriendListErrorType? _errorType;

  List<FriendItem> _friends = [];

  String? get errorMessage {
    switch (_errorType) {
      case FriendListErrorType.system:
        return 'Unable to load friends. Please try again.';
      case FriendListErrorType.network:
        return 'Request failed. Please check your connection.';
      case null:
        return null;
    }
  }

  List<FriendItem> get friends => List.unmodifiable(_friends);

  Future<void> loadFriends() async {
    _errorType = null;
    notifyListeners();

    try {
      final currentUserId = await AuthService.instance.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('Not signed in');
      }

      final fetchedFriends = await _tripFriendService.getAllFriends();

      // Only show accepted friendships, not pending/undecided rows.
      final acceptedFriends = fetchedFriends
          .where((f) => f.friendStatus == FriendStatus.friend)
          .toList();

      // Resolve "the other person" in each friendship relative to me.
      final otherUserIds = acceptedFriends
          .map((f) => f.userId == currentUserId ? f.friendUserId : f.userId)
          .toSet()
          .toList();

      final accountResults = await Future.wait(
        otherUserIds.map((userId) async {
          try {
            return await _tripAccountService.getAccountById(userId);
          } catch (error) {
            debugPrint('LOAD FRIEND ACCOUNT ERROR ($userId): $error');
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

      _friends = acceptedFriends.map((f) {
        final otherUserId = f.userId == currentUserId ? f.friendUserId : f.userId;
        final account = accountsByUserId[otherUserId];

        return FriendItem(
          userId: otherUserId,
          name: account != null
              ? '${account.firstName} ${account.lastName}'.trim()
              : 'Unknown User',
          username: account != null ? '@${account.username}' : '',
          profileImageUrl: account?.profilePicture,
          reliabilityScore: account?.reliabilityScore.round() ?? 0,
        );
      }).toList();

      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('LOAD FRIENDS ERROR: $error');
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