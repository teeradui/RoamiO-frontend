import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:roamio_frontend/theme/colors.dart';

enum TripStatus {
  upcoming,
  active,
  completed,
}

class TripCardViewModel extends ChangeNotifier {
  TripCardViewModel({
    required this.tripId,
    required this.tripName,
    required this.startDate,
    required this.photoCount,
    required this.placeCount,
    required this.status,
    this.imageUrl,
    this.memberCount = 0,
  });

  final String tripId;
  final String tripName;
  final String startDate;
  final int photoCount;
  final int placeCount;
  final int memberCount;
  final String? imageUrl;

  TripStatus status;

  String get statusText {
    switch (status) {
      case TripStatus.upcoming:
        return "Upcoming";
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

  void updateStatus(TripStatus newStatus) {
    status = newStatus;
    notifyListeners();
  }
}