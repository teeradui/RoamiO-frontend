import 'package:flutter/material.dart';
import 'package:roamio_frontend/models/services/overview_sevice.dart';
import 'package:roamio_frontend/viewmodels/trip_detail_view_model.dart';

class OverviewPlace {
  final String name;
  final String type;
  final String timeText;

  const OverviewPlace({
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

  const OverviewActivityType({
    required this.label,
    required this.count,
    required this.bgColor,
    required this.textColor,
  });
}

class OverviewSectionViewModel extends ChangeNotifier {
  OverviewSectionViewModel({
    required this.tripId,
    required this.tripStatus,
    OverviewService? overviewService,
  }) : _overviewService = overviewService ?? OverviewService();

  final String tripId;
  final TripStatus tripStatus;
  final OverviewService _overviewService;

  int photosCount = 0;
  int placesCount = 0;
  int activitiesCount = 0;

  List<OverviewActivityType> activityTypes = [];
  List<OverviewPlace> places = [];

  bool isLoading = false;
  String? errorMessage;

  bool get isUpcoming => tripStatus == TripStatus.upcoming;

  bool get isActive => tripStatus == TripStatus.active;

  bool get hasPlaces => places.isNotEmpty;

  bool get hasActivityTypes => activityTypes.isNotEmpty;

  bool get isEmpty {
    return photosCount == 0 &&
        placesCount == 0 &&
        activitiesCount == 0;
  }

  Future<void> loadOverview() async {
    errorMessage = null;

    // Upcoming ยังไม่เริ่ม tracking
    if (isUpcoming) {
      _clearData();
      notifyListeners();
      return;
    }

    // ตอนนี้รองรับแค่ Upcoming และ Active
    if (!isActive) {
      _clearData();
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final response = await _overviewService.getTripOverview(
        tripId,
      );

      photosCount = response.photosCount;
      placesCount = response.placesCount;
      activitiesCount = response.activitiesCount;

      places = response.places
          .map(
            (place) => OverviewPlace(
              name: place.name,
              type: place.type,
              timeText: _formatTime(place.timeText),
            ),
          )
          .toList();

      activityTypes = response.activityTypes
          .map(
            (activity) => OverviewActivityType(
              label: activity.label,
              count: activity.count,
              bgColor: _getActivityBackgroundColor(
                activity.label,
              ),
              textColor: _getActivityTextColor(
                activity.label,
              ),
            ),
          )
          .toList();
    } catch (error, stackTrace) {
      debugPrint('LOAD OVERVIEW ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      _clearData();
      errorMessage = 'Unable to load trip overview.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _clearData() {
    photosCount = 0;
    placesCount = 0;
    activitiesCount = 0;
    places = [];
    activityTypes = [];
  }

  String _formatTime(String value) {
    if (value.trim().isEmpty) return '';

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      return value;
    }

    final localTime = parsed.toLocal();
    final hour = localTime.hour;
    final minute = localTime.minute.toString().padLeft(2, '0');
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour >= 12 ? 'PM' : 'AM';

    return '$displayHour:$minute $period';
  }

  Color _getActivityBackgroundColor(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'food':
        return const Color(0x3BFFE37A);

      case 'sightseeing':
      case 'outdoor':
        return const Color(0x42CCFF91);

      case 'accommodation':
        return const Color(0x268E5CF7);

      case 'transit':
        return const Color(0x2636A1C7);

      default:
        return const Color(0x1FDCC6B4);
    }
  }

  Color _getActivityTextColor(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'food':
        return const Color(0xFFECA205);

      case 'sightseeing':
      case 'outdoor':
        return const Color(0xFFAFCA15);

      case 'accommodation':
        return const Color(0xFF8E5CF7);

      case 'transit':
        return const Color(0xFF36A1C7);

      default:
        return const Color(0xFFAB653A);
    }
  }
}