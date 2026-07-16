import 'package:flutter/material.dart';
import 'package:roamio_frontend/models/services/trip_activity_service.dart';
import 'package:roamio_frontend/models/trip_activity_model.dart' as trip_model;

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
  final String tripId;
  final TripActivityService _tripActivityService;

  ActivitiesSectionViewModel({
    required this.tripId,
    TripActivityService? tripActivityService,
  }) : _tripActivityService = tripActivityService ?? TripActivityService();

  List<TripActivityItem> activities = [];

  bool isLoading = false;
  String? errorMessage;

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

  ActivityType _mapActivityType(String? value) {
    switch (value) {
      case 'Food':
        return ActivityType.food;
      case 'Accommodation':
        return ActivityType.accommodation;
      case 'Transit':
        return ActivityType.transit;
      case 'Sightseeing':
      default:
        return ActivityType.sightseeing;
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDuration(num? minutes) {
    if (minutes == null) return '';
    final total = minutes.round();
    if (total < 60) return '$total min';
    final hrs = total ~/ 60;
    final mins = total % 60;
    if (mins == 0) return '$hrs hr${hrs == 1 ? '' : 's'}';
    return '$hrs hr${hrs == 1 ? '' : 's'} $mins min';
  }

  TripActivityItem _toItem(trip_model.TripActivity activity) {
    return TripActivityItem(
      id: activity.activityId,
      timeText: _formatTime(activity.startTime),
      activityType: _mapActivityType(activity.activityType),
      placeType: activity.locationType ?? '',
      placeName: activity.locationName ?? '',
      durationText: _formatDuration(activity.duration),
    );
  }

  Future<void> loadActivities() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _tripActivityService.getTimeline(tripId);
      activities = fetched.map(_toItem).toList();
    } catch (e) {
      errorMessage = "Unable to load activities.";
    }

    isLoading = false;
    notifyListeners();
  }
}