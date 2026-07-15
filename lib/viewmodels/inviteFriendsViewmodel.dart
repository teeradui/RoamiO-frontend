import 'package:flutter/material.dart';
import 'package:roamio_frontend/models/friendModel.dart';
import 'package:roamio_frontend/models/services/tripInviteService.dart';

class InviteFriendsViewModel extends ChangeNotifier {
  final TripInviteService _tripInviteService;
 
  InviteFriendsViewModel({TripInviteService? tripInviteService})
      : _tripInviteService = tripInviteService ?? TripInviteService();

  final List<FriendModel> friends = [
    FriendModel(id: "1", username: "mali", reliabilityScore: 92),
    FriendModel(id: "2", username: "punpun", reliabilityScore: 88),
    FriendModel(id: "3", username: "beam", reliabilityScore: 76),
  ];

  int get selectedCount => selectedFriendIds.length;

  final Set<String> selectedFriendIds = {};

  String searchQuery = "";

  bool isSubmitting = false;
  String? errorMessage;


  List get filteredFriends {
    if (searchQuery.trim().isEmpty) {
      return friends;
    }

    final query = searchQuery.toLowerCase();

    return friends.where((friend) {
      return friend.username.toLowerCase().contains(query);
    }).toList();
  }

  bool get hasFilteredFriends => filteredFriends.isNotEmpty;

  void searchFriends(String value) {
    searchQuery = value;
    notifyListeners();
  }

  bool get hasFriends => friends.isNotEmpty;

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
        failedUsernames.add(friend.isNotEmpty ? friend.first.username : friendId);
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
