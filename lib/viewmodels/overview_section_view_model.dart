import 'dart:io';

import 'package:flutter/material.dart';
import 'package:roamio_frontend/models/services/overview_sevice.dart';
import 'package:roamio_frontend/viewmodels/trip_detail_view_model.dart';
import 'package:roamio_frontend/models/services/trip_summary_service.dart';
import 'package:roamio_frontend/models/trip_summary_model.dart';

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

class OverviewRadarItem {
  final String label;
  final double value;

  const OverviewRadarItem({required this.label, required this.value});
}

class OverviewSectionViewModel extends ChangeNotifier {
  OverviewSectionViewModel({
    required this.tripId,
    required this.tripStatus,
    OverviewService? overviewService,
    TripSummaryService? tripSummaryService,
  }) : _overviewService = overviewService ?? OverviewService(),
       _tripSummaryService = tripSummaryService ?? TripSummaryService();

  final String tripId;
  final TripStatus tripStatus;
  final OverviewService _overviewService;
  final TripSummaryService _tripSummaryService;

  int photosCount = 0;
  int placesCount = 0;
  int activitiesCount = 0;

  List<OverviewActivityType> activityTypes = [];
  List<OverviewPlace> places = [];

  double totalDistanceKm = 0;
  String totalDurationText = '';

  List<OverviewRadarItem> groupActivityStats = [];
  List<OverviewRadarItem> myActivityStats = [];

  bool isLoading = false;
  String? errorMessage;

  bool get isUpcoming => tripStatus == TripStatus.upcoming;

  bool get isActive => tripStatus == TripStatus.active;

  bool get isCompleted => tripStatus == TripStatus.completed;

  bool get hasGroupActivityStats => groupActivityStats.isNotEmpty;

  bool get hasMyActivityStats => myActivityStats.isNotEmpty;

  bool get hasPlaces => places.isNotEmpty;

  bool get hasActivityTypes => activityTypes.isNotEmpty;

  bool get isEmpty {
    return photosCount == 0 && placesCount == 0 && activitiesCount == 0;
  }

  bool get hasCompletedSummary {
    return totalDistanceKm > 0 ||
        totalDurationText.trim().isNotEmpty ||
        placesCount > 0 ||
        activitiesCount > 0 ||
        hasGroupActivityStats ||
        hasMyActivityStats;
  }

  /*Future<void> loadOverview() async {
    errorMessage = null;

    // Upcoming ยังไม่เริ่ม tracking
    if (isUpcoming) {
      _clearData();
      notifyListeners();
      return;
    }

    // ตอนนี้รองรับแค่ Upcoming และ Active
    if (!isActive && !isCompleted) {
      _clearData();
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final response = await _overviewService.getTripOverview(tripId);

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
              bgColor: _getActivityBackgroundColor(activity.label),
              textColor: _getActivityTextColor(activity.label),
            ),
          )
          .toList();
      if (isCompleted) {
        // TODO: map จาก backend summary endpoint ภายหลัง
        //
        // totalDistanceKm = response.totalDistanceKm;
        // totalDurationText = response.totalDurationText;
        //
        // groupActivityStats =
        //     response.groupActivityStats
        //         .map(
        //           (item) => OverviewRadarItem(
        //             label: item.label,
        //             value: item.value,
        //           ),
        //         )
        //         .toList();
        //
        // myActivityStats =
        //     response.myActivityStats
        //         .map(
        //           (item) => OverviewRadarItem(
        //             label: item.label,
        //             value: item.value,
        //           ),
        //         )
        //         .toList();
      }
    } on SocketException {
      // SRS-139
      _clearData();

      errorMessage = 'Request failed. Please check your connection.';
    } catch (error, stackTrace) {
      debugPrint('LOAD OVERVIEW ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      _clearData();
      final message = error.toString().toLowerCase();

      if (message.contains('socketexception') ||
          message.contains('connection refused') ||
          message.contains('network is unreachable') ||
          message.contains('failed host lookup') ||
          message.contains('timed out')) {
        // SRS-139
        errorMessage = 'Request failed. Please check your connection.';
      } else {
        // SRS-138
        errorMessage = 'Unable to load trip summary. Please try again.';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }*/

  //mock data
    Future<void> _loadCompletedFromBackend() async {
    isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _tripSummaryService.getSummary(tripId),
        _tripSummaryService.getActivityGraphData(tripId),
      ]);

      final summary = results[0] as TripSummary;
      final graphData = results[1] as ActivityGraphData;

      photosCount = summary.photos.length;
      activitiesCount = summary.activities.length;

      final distinctLocations = summary.activities
          .map((a) => a.locationName)
          .where((name) => name != null && name.trim().isNotEmpty)
          .toSet();
      placesCount = distinctLocations.length;

      places = summary.activities
          .where((a) => a.locationName != null && a.locationName!.trim().isNotEmpty)
          .map(
            (a) => OverviewPlace(
              name: a.locationName!,
              type: a.locationType ?? 'WIP (need to implement)',
              timeText: a.startTime != null
                  ? _formatTime(a.startTime!.toIso8601String())
                  : 'WIP (need to implement)',
            ),
          )
          .toList();

      // Group activity-type tally, derived client-side from all trip activities.
      final groupTally = <String, int>{};
      for (final activity in summary.activities) {
        final type = activity.activityType?.trim();
        if (type == null || type.isEmpty) continue;
        groupTally[type] = (groupTally[type] ?? 0) + 1;
      }

      activityTypes = groupTally.entries
          .map(
            (entry) => OverviewActivityType(
              label: entry.key,
              count: entry.value,
              bgColor: _getActivityBackgroundColor(entry.key),
              textColor: _getActivityTextColor(entry.key),
            ),
          )
          .toList();

      groupActivityStats = groupTally.entries
          .map((entry) => OverviewRadarItem(label: entry.key, value: entry.value.toDouble()))
          .toList();

      myActivityStats = graphData.activityTypeCounts
          .map((item) => OverviewRadarItem(label: item.activityType, value: item.count.toDouble()))
          .toList();

      // WIP: no backend field yet for real trip distance/duration.
      totalDistanceKm = 0;
      totalDurationText = 'WIP (need to implement)';
    } on SocketException {
      _clearData();
      errorMessage = 'Request failed. Please check your connection.';
    } catch (error, stackTrace) {
      debugPrint('LOAD OVERVIEW (COMPLETED) ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      _clearData();
      final message = error.toString().toLowerCase();

      if (message.contains('socketexception') ||
          message.contains('connection refused') ||
          message.contains('network is unreachable') ||
          message.contains('failed host lookup') ||
          message.contains('timed out')) {
        errorMessage = 'Request failed. Please check your connection.';
      } else {
        errorMessage = 'Unable to load trip summary. Please try again.';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOverview() async {
    errorMessage = null;

    if (isUpcoming) {
      _clearData();
      notifyListeners();
      return;
    }

    if (isCompleted) {
      await _loadCompletedFromBackend();
      return;
    }

    if (!isActive) {
      _clearData();
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final response = await _overviewService.getTripOverview(tripId);

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
              bgColor: _getActivityBackgroundColor(activity.label),
              textColor: _getActivityTextColor(activity.label),
            ),
          )
          .toList();
    } on SocketException {
      _clearData();
      errorMessage = 'Request failed. Please check your connection.';
    } catch (error, stackTrace) {
      debugPrint('LOAD OVERVIEW ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      _clearData();
      final message = error.toString().toLowerCase();

      if (message.contains('socketexception') ||
          message.contains('connection refused') ||
          message.contains('network is unreachable') ||
          message.contains('failed host lookup') ||
          message.contains('timed out')) {
        errorMessage = 'Request failed. Please check your connection.';
      } else {
        errorMessage = 'Unable to load trip summary. Please try again.';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

//mock data 
  

  void _clearData() {
    photosCount = 0;
    placesCount = 0;
    activitiesCount = 0;

    totalDistanceKm = 0;
    totalDurationText = '';

    places = [];
    activityTypes = [];
    groupActivityStats = [];
    myActivityStats = [];
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

class RadarActivityData {
  final String label;
  final double groupValue;
  final double personalValue;

  const RadarActivityData({
    required this.label,
    required this.groupValue,
    required this.personalValue,
  });
}
