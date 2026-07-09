import 'package:flutter/material.dart';

class OverviewPlace {
  final String name;
  final String type;
  final String timeText;

  OverviewPlace({
    required this.name,
    required this.type,
    required this.timeText,
  });
}

class OverviewActivityType {
  final String label;
  final int count;
  final Color bgColor;
  final Color textColor;

  OverviewActivityType({
    required this.label,
    required this.count,
    required this.bgColor,
    required this.textColor,
  });
}

class OverviewSectionViewModel extends ChangeNotifier {
  int photosCount = 3;
  int placesCount = 3;
  int activitiesCount = 2;

  final List<OverviewActivityType> activityTypes = [
    OverviewActivityType(
      label: "Outdoor",
      count: 1,
      bgColor: const Color(0x42CCFF91),
      textColor: const Color(0xFFAFCA15),
    ),
    OverviewActivityType(
      label: "Food",
      count: 1,
      bgColor: const Color(0x3BFFE37A),
      textColor: const Color(0xFFECA205),
    ),
  ];

  final List<OverviewPlace> places = [
    OverviewPlace(
      name: "Chiang Mai University",
      type: "University",
      timeText: "09:30 AM",
    ),
    OverviewPlace(
      name: "One Nimman",
      type: "Shopping Area",
      timeText: "12:45 PM",
    ),
    OverviewPlace(
      name: "Tha Phae Gate",
      type: "Landmark",
      timeText: "04:10 PM",
    ),
  ];

  bool get isEmpty {
    return photosCount == 0 && placesCount == 0 && activitiesCount == 0;
  }

  bool get hasPlaces => places.isNotEmpty;
  bool get hasActivityTypes => activityTypes.isNotEmpty;

  Future<void> loadOverview() async {
    // TODO: call backend later
    notifyListeners();
  }
}