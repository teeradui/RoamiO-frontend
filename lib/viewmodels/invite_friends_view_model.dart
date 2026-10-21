import 'package:flutter/material.dart';
import 'package:roamio_frontend/models/friend_model.dart';
import 'package:roamio_frontend/models/services/trip_invite_service.dart';
import 'package:roamio_frontend/models/services/trip_friend_service.dart';
import 'package:roamio_frontend/models/services/auth_service.dart';
import 'package:roamio_frontend/models/trip_friend_model.dart';

class InviteFriendsViewModel extends ChangeNotifier {
  final TripInviteService _tripInviteService;
  final TripFriendService _tripFriendService;

  InviteFriendsViewModel({
    TripInviteService? tripInviteService,
    TripFriendService? tripFriendService,
  }) : _tripInviteService = tripInviteService ?? TripInviteService(),
       _tripFriendService = tripFriendService ?? TripFriendService();

  final List<FriendModel> friends = [];

  int get selectedCount => selectedFriendIds.length;

  final Set<String> selectedFriendIds = {};

  String searchQuery = "";

  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  List<FriendModel> get filteredFriends {
    if (searchQuery.trim().isEmpty) {
      return friends;
    }

    final query = searchQuery.toLowerCase();

    return friends.where((friend) {
      return friend.username.toLowerCase().contains(query);
    }).toList();
  }

  bool get hasFilteredFriends => filteredFriends.isNotEmpty;

  bool get hasFriends => friends.isNotEmpty;

  Future<void> loadFriends() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final currentUserId = await AuthService.instance.getCurrentUserId();

      if (currentUserId == null) {
        throw Exception('Not signed in');
      }

      final tripFriends = await _tripFriendService.getAllFriends();

      // Only show accepted friendships.
      final acceptedFriends = tripFriends
          .where((friend) => friend.friendStatus == FriendStatus.friend)
          .toList();

      // Resolve the other user's ID and remove duplicates.
      final uniqueFriends = <String, FriendModel>{};

      for (final friend in acceptedFriends) {
        final otherUserId = friend.userId == currentUserId
            ? friend.friendUserId
            : friend.userId;

        uniqueFriends[otherUserId] = FriendModel(
          id: otherUserId,
          username: friend.username,
          reliabilityScore: 0,
          profileImageUrl: friend.profilePicture,
        );
      }

      friends
        ..clear()
        ..addAll(uniqueFriends.values);
    } catch (e) {
      errorMessage = 'Could not load friends.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void searchFriends(String value) {
    searchQuery = value;
    notifyListeners();
  }

  bool isSelected(String friendId) {
    return selectedFriendIds.contains(friendId);
  }

  void toggleFriend(String friendId) {
    if (selectedFriendIds.contains(friendId)) {
      selectedFriendIds.remove(friendId);
    } else {
      selectedFriendIds.add(friendId);
    }

    notifyListeners();
  }

  Future<bool> sendInvites(String tripId) async {
    if (selectedFriendIds.isEmpty) return true;

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    final failedUsernames = <String>[];

    for (final friendId in selectedFriendIds) {
      try {
        await _tripInviteService.sendInvite(tripId, friendId);
      } catch (e) {
        final friend = friends.where((f) => f.id == friendId).toList();

        failedUsernames.add(
          friend.isNotEmpty ? friend.first.username : friendId,
        );
      }
    }

    isSubmitting = false;

    if (failedUsernames.isNotEmpty) {
      errorMessage = 'Could not invite: ${failedUsernames.join(", ")}';
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }
}
