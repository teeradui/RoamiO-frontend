import 'package:flutter/material.dart';
import 'package:roamio_frontend/models/services/tripMemberService.dart';
import 'package:roamio_frontend/models/services/tripService.dart';

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
  final String tripId;
  final TripMemberService _tripMemberService;
  final TripService _tripService;
 
  MemberSectionViewModel({
    required this.tripId,
    TripMemberService? tripMemberService,
    TripService? tripService,
  })  : _tripMemberService = tripMemberService ?? TripMemberService(),
        _tripService = tripService ?? TripService();
 
  // TODO: there is no concept of "current logged-in user" wired up
  // anywhere in the app yet (no auth; the backend still hardcodes
  // ownerId = 1). This can't be correctly computed until real auth exists.
  // Hardcoded true for now so the owner-only UI (Add/Remove buttons) is
  // visible during development — replace with a real comparison once
  // there's an actual signed-in user id available.
  bool isCurrentUserOwner = true;
 
  List<TripMemberItem> members = [];
 
  bool isLoading = false;
  String? errorMessage;

  int get memberCount => members.length;

    Future<void> loadMembers() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
 
    try {
      final fetchedMembers = await _tripMemberService.getMembersByTrip(tripId);
      final trip = await _tripService.getTripById(tripId);
      final createdBy = trip.createdBy;
 
      // NOTE: TripMemberResponseDto has no username/avatar field — only
      // userId. Falling back to userId as the display label until a
      // user-lookup endpoint exists (same gap as tripDetailViewmodel.dart).
      members = fetchedMembers
          .map((m) => TripMemberItem(
                id: m.participantId,
                username: m.userId,
                isOwner: m.userId == createdBy,
              ))
          .toList();
    } catch (e) {
      errorMessage = "Unable to load members.";
    }
 
    isLoading = false;
    notifyListeners();
  }

    Future<void> removeMember(String participantId) async {
    final previousMembers = members;
    members = members.where((m) => m.id != participantId).toList();
    notifyListeners();
 
    try {
      await _tripMemberService.removeMember(tripId, participantId);
    } catch (e) {
      // Roll back on failure.
      members = previousMembers;
      errorMessage = "Unable to remove member.";
      notifyListeners();
    }
  }

}