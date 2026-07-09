import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:roamio_frontend/theme/colors.dart';

enum TripStatus { upcoming, active, completed }

class TripMember {
  final String username;
  final String? imageUrl;

  TripMember({required this.username, this.imageUrl});
}

enum TripDetailSection { overview, map, activities, photo, member }

class TripDetailViewModel extends ChangeNotifier {
  // Mock data ก่อน
  String tripName = "Japan Autumn Trip";
  String destination = "Japan, Tokyo";
  String? meetingPoint = null;

  String startDate = "15 May 2026";
  String endDate = "20 May 2026";
  String startTime = "09:00 AM";

  double distanceKm = 0.0;

  TripStatus status = TripStatus.upcoming;

  List<TripMember> members = [
    TripMember(username: "Mali"),
    TripMember(username: "Punpun"),
    TripMember(username: "Beam"),
  ];

  bool get isUpcoming => status == TripStatus.upcoming;
  bool get isActive => status == TripStatus.active;
  bool get isCompleted => status == TripStatus.completed;

  String get statusText {
    switch (status) {
      case TripStatus.upcoming:
        return "Starts $startDate at $startTime";
      case TripStatus.active:
        return "Active";
      case TripStatus.completed:
        return "Completed";
    }
  }

  dynamic get statusIcon {
  switch (status) {
    case TripStatus.upcoming:
      return HugeIcons.strokeRoundedClock01;
    case TripStatus.active:
      return HugeIcons.strokeRoundedNavigation03;
    case TripStatus.completed:
      return HugeIcons.strokeRoundedCheckmarkCircle02;
  }
}

  Color get statusColor {
    switch (status) {
      case TripStatus.upcoming:
        return AppColors.textUpcoming;
      case TripStatus.active:
        return AppColors.textActive;
      case TripStatus.completed:
        return AppColors.textCompleted;
    }
  }

  Color get statusBackgroundColor {
    switch (status) {
      case TripStatus.upcoming:
        return AppColors.bgUpcoming;

      case TripStatus.active:
        return AppColors.bgActive;

      case TripStatus.completed:
        return AppColors.bgCompleted;
    }
  }

  String get meetingPointText {
    return meetingPoint ?? "Didn’t set the meeting point";
  }

  void deleteTrip() {
    // TODO: call backend delete
  }

  void endTrip() {
    // TODO: call backend end trip
  }

  TripDetailSection selectedSection = TripDetailSection.overview;

  void selectSection(TripDetailSection section) {
    selectedSection = section;
    notifyListeners();
  }

  bool isSelectedSection(TripDetailSection section) {
    return selectedSection == section;
  }
}
