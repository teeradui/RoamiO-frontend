import 'package:flutter/material.dart';

enum ActivityType {
  food,
  sightseeing,
  accommodation,
  transit,
}

class TripActivityItem {
  final String id;
  final String timeText;
  final ActivityType activityType;
  final String placeType;
  final String placeName;
  final String durationText;

  TripActivityItem({
    required this.id,
    required this.timeText,
    required this.activityType,
    required this.placeType,
    required this.placeName,
    required this.durationText,
  });
}

class ActivitiesSectionViewModel extends ChangeNotifier {
  final List<TripActivityItem> activities = [
    TripActivityItem(
      id: "1",
      timeText: "14:00",
      activityType: ActivityType.sightseeing,
      placeType: "Beach",
      placeName: "Kata Beach",
      durationText: "3 hrs",
    ),
    TripActivityItem(
      id: "2",
      timeText: "16:00",
      activityType: ActivityType.food,
      placeType: "Restaurant",
      placeName: "Kata Beach Cafe",
      durationText: "1 hr",
    ),
    TripActivityItem(
      id: "3",
      timeText: "18:30",
      activityType: ActivityType.transit,
      placeType: "Transport",
      placeName: "Local Bus",
      durationText: "25 min",
    ),
    TripActivityItem(
      id: "4",
      timeText: "20:00",
      activityType: ActivityType.accommodation,
      placeType: "Hotel",
      placeName: "The Sea Hotel",
      durationText: "Overnight",
    ),
  ];

  bool get hasActivities => activities.isNotEmpty;

  String getActivityLabel(ActivityType type) {
    switch (type) {
      case ActivityType.food:
        return "Food";
      case ActivityType.sightseeing:
        return "Sightseeing";
      case ActivityType.accommodation:
        return "Accommodation";
      case ActivityType.transit:
        return "Transit";
    }
  }

  Color getActivityTextColor(ActivityType type) {
    switch (type) {
      case ActivityType.food:
        return const Color(0xFFECA205);
      case ActivityType.sightseeing:
        return const Color(0xFFF7630D);
      case ActivityType.accommodation:
        return const Color(0xFF8E5CF7);
      case ActivityType.transit:
        return const Color(0xFF36A1C7);
    }
  }

  Color getActivityBgColor(ActivityType type) {
    switch (type) {
      case ActivityType.food:
        return const Color(0x3BFFE37A);
      case ActivityType.sightseeing:
        return const Color(0x30FF7D5C);
      case ActivityType.accommodation:
        return const Color(0x268E5CF7);
      case ActivityType.transit:
        return const Color(0x2636A1C7);
    }
  }

  List<Color> getActivityGradient(ActivityType type) {
    switch (type) {
      case ActivityType.food:
        return const [
          Color(0xFFFFE37A),
          Color(0xFFECA205),
          Color(0xFFF7630D),
        ];

      case ActivityType.sightseeing:
        return const [
          Color(0xFFFF7D5C),
          Color(0xFFF7630D),
          Color(0xFFFFA58D),
        ];

      case ActivityType.accommodation:
        return const [
          Color(0xFFE8D7FF),
          Color(0xFFB98CFF),
          Color(0xFF8E5CF7),
        ];

      case ActivityType.transit:
        return const [
          Color(0xFFBDEFFF),
          Color(0xFF36A1C7),
          Color(0xFF2D7DFB),
        ];
    }
  }

  Future<void> loadActivities() async {
    // TODO: call backend later
    notifyListeners();
  }
}