//need to update to use different route

import 'package:flutter/material.dart';

import 'package:roamio_frontend/models/services/trip_summary_service.dart';

enum StoryActivityType {
  food,
  sightseeing,
  accommodation,
  transit,
  other,
}

class StoryActivityStat {
  final StoryActivityType type;
  final String label;
  final int count;
  final IconData icon;

  const StoryActivityStat({
    required this.type,
    required this.label,
    required this.count,
    required this.icon,
  });
}

class StoryActivitySummaryViewModel extends ChangeNotifier {
  StoryActivitySummaryViewModel({
    required this.tripId,
    TripSummaryService? tripSummaryService,
  }) : _tripSummaryService = tripSummaryService ?? TripSummaryService();

  final String tripId;
  final TripSummaryService _tripSummaryService;

  List<StoryActivityStat> activityStats = [];

  bool isLoading = false;
  String? errorMessage;

  int get totalActivities {
    return activityStats.fold(
      0,
      (sum, item) => sum + item.count,
    );
  }

  StoryActivityStat? get mostActivity {
    if (activityStats.isEmpty) {
      return null;
    }

    return activityStats.reduce(
      (current, next) {
        return next.count > current.count ? next : current;
      },
    );
  }

  bool get hasActivities => activityStats.isNotEmpty;

  StoryActivityType _mapType(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'food':
        return StoryActivityType.food;
      case 'sightseeing':
        return StoryActivityType.sightseeing;
      case 'accommodation':
        return StoryActivityType.accommodation;
      case 'transit':
        return StoryActivityType.transit;
      default:
        return StoryActivityType.other;
    }
  }

  String _labelFor(StoryActivityType type, String rawLabel) {
    switch (type) {
      case StoryActivityType.food:
        return 'Food';
      case StoryActivityType.sightseeing:
        return 'Sightseeing';
      case StoryActivityType.accommodation:
        return 'Accommodation';
      case StoryActivityType.transit:
        return 'Transit';
      case StoryActivityType.other:
        // Keep the backend's original label so distinct "other" types
        // (e.g. "Outdoor", "Shopping") aren't all flattened to one name.
        return rawLabel.trim().isNotEmpty ? rawLabel : 'Other';
    }
  }

  IconData _iconFor(StoryActivityType type) {
    switch (type) {
      case StoryActivityType.food:
        return Icons.restaurant_rounded;
      case StoryActivityType.sightseeing:
        return Icons.photo_camera_rounded;
      case StoryActivityType.accommodation:
        return Icons.hotel_rounded;
      case StoryActivityType.transit:
        return Icons.directions_car_rounded;
      case StoryActivityType.other:
        return Icons.category_rounded;
    }
  }

  Future<void> loadActivitySummary() async {
    debugPrint('========== LOAD STORY ACTIVITY SUMMARY ==========');
    debugPrint('Trip ID: $tripId');

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final graphData = await _tripSummaryService.getActivityGraphData(tripId);

      activityStats = graphData.activityTypeCounts.map((item) {
        final type = _mapType(item.activityType);

        return StoryActivityStat(
          type: type,
          label: _labelFor(type, item.activityType),
          count: item.count,
          icon: _iconFor(type),
        );
      }).toList();

      debugPrint('ACTIVITY SUMMARY LOAD SUCCESS');
      debugPrint('Total activities: $totalActivities');
      debugPrint('Most activity: ${mostActivity?.label} (${mostActivity?.count})');

      for (final activity in activityStats) {
        debugPrint('${activity.label}: ${activity.count}');
      }
    } catch (error, stackTrace) {
      debugPrint('LOAD STORY ACTIVITY SUMMARY ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      activityStats = [];

      final message = error.toString().toLowerCase();

      if (message.contains('socketexception') ||
          message.contains('connection refused') ||
          message.contains('failed host lookup') ||
          message.contains('network is unreachable') ||
          message.contains('timed out')) {
        errorMessage = 'Request failed. Please check your connection.';
      } else {
        errorMessage = 'Unable to load activity summary.';
      }
    } finally {
      isLoading = false;

      debugPrint('Activity type count: ${activityStats.length}');
      debugPrint('===============================================');

      notifyListeners();
    }
  }

  Color getTextColor(StoryActivityType type) {
    switch (type) {
      case StoryActivityType.food:
        return const Color(0xFFECA205);

      case StoryActivityType.sightseeing:
        return const Color(0xFFF7630D);

      case StoryActivityType.accommodation:
        return const Color(0xFF8E5CF7);

      case StoryActivityType.transit:
        return const Color(0xFF36A1C7);

      case StoryActivityType.other:
        return const Color(0xFFAB653A);
    }
  }

  Color getBackgroundColor(StoryActivityType type) {
    switch (type) {
      case StoryActivityType.food:
        return const Color(0x3BFFE37A);

      case StoryActivityType.sightseeing:
        return const Color(0x30FF7D5C);

      case StoryActivityType.accommodation:
        return const Color(0x268E5CF7);

      case StoryActivityType.transit:
        return const Color(0x2636A1C7);

      case StoryActivityType.other:
        return const Color(0x1FDCC6B4);
    }
  }
}