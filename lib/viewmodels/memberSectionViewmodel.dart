import 'package:flutter/material.dart';

class TripMemberItem {
  final String id;
  final String username;
  final String? profileImageUrl;
  final bool isOwner;

  TripMemberItem({
    required this.id,
    required this.username,
    this.profileImageUrl,
    this.isOwner = false,
  });
}

class MemberSectionViewModel extends ChangeNotifier {
  // mock: ตอนนี้ให้ user ปัจจุบันเป็น owner ก่อน
  bool isCurrentUserOwner = true;

  final List<TripMemberItem> members = [
    TripMemberItem(
      id: "1",
      username: "Teedy",
      isOwner: true,
    ),
    TripMemberItem(
      id: "2",
      username: "Cherry",
    ),
    TripMemberItem(
      id: "3",
      username: "Pang",
    ),
  ];

  int get memberCount => members.length;

  void addMember() {
    // TODO: later go to add member screen
  }

  void removeMember(String id) {
    members.removeWhere((member) => member.id == id);
    notifyListeners();
  }
}