import 'package:flutter/material.dart';
import 'package:roamio_frontend/models/services/trip_member_service.dart';
import 'package:roamio_frontend/models/services/trip_service.dart';

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

/*import 'package:flutter/material.dart';
import 'package:roamio_frontend/models/services/trip_member_service.dart';
import 'package:roamio_frontend/models/services/trip_service.dart';

class TripMemberItem {
  final String id;
  final String userId;
  final String username;
  final String? profileImageUrl;
  final bool isOwner;

  const TripMemberItem({
    required this.id,
    required this.userId,
    required this.username,
    required this.isOwner,
    this.profileImageUrl,
  });
}

class MemberSectionViewModel extends ChangeNotifier {
  MemberSectionViewModel({
    required this.tripId,
    TripMemberService? tripMemberService,
    TripService? tripService,
  }) : _tripMemberService =
           tripMemberService ?? TripMemberService(),
       _tripService = tripService ?? TripService();

  final String tripId;
  final TripMemberService _tripMemberService;
  final TripService _tripService;

  // TODO: เปลี่ยนเป็น user ID จากระบบ Authentication
  static const String currentUserId = '1';

  bool isCurrentUserOwner = false;

  List<TripMemberItem> members = [];

  bool isLoading = false;
  String? errorMessage;

  int get memberCount => members.length;

  Future<void> loadMembers() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _tripMemberService.getMembersByTrip(
          tripId,
          forceRefresh: true,
        ),
        _tripService.getTripById(
          tripId,
          forceRefresh: true,
        ),
      ]);

      final fetchedMembers = results[0] as List;
      final trip = results[1];

      final createdBy = trip.createdBy.toString();

      isCurrentUserOwner = currentUserId == createdBy;

      members = fetchedMembers.map((member) {
        final username = member.username.toString().trim();
        final profileImageUrl =
            member.profileImageUrl?.toString().trim();

        return TripMemberItem(
          id: member.participantId.toString(),
          userId: member.userId.toString(),
          username: username.isNotEmpty
              ? username
              : 'Unknown User',
          profileImageUrl:
              profileImageUrl != null &&
                  profileImageUrl.isNotEmpty
              ? profileImageUrl
              : null,
          isOwner: member.userId.toString() == createdBy,
        );
      }).toList();

      // ให้ Owner อยู่บนสุด
      members.sort((a, b) {
        if (a.isOwner == b.isOwner) return 0;
        return a.isOwner ? -1 : 1;
      });
    } catch (error, stackTrace) {
      debugPrint('LOAD TRIP MEMBERS ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage = 'Unable to load members.';
      members = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeMember(String participantId) async {
    final previousMembers = List<TripMemberItem>.from(members);

    members = members
        .where((member) => member.id != participantId)
        .toList();

    notifyListeners();

    try {
      await _tripMemberService.removeMember(
        tripId,
        participantId,
      );
    } catch (error, stackTrace) {
      debugPrint('REMOVE TRIP MEMBER ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      members = previousMembers;
      errorMessage = 'Unable to remove member.';
      notifyListeners();
    }
  }
}*/