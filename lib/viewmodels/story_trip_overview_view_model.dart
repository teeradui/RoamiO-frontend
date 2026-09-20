import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:roamio_frontend/models/services/trip_summary_service.dart';
import 'package:roamio_frontend/models/trip_summary_model.dart';

class StoryTripOverviewStat {
  final String label;
  final String value;
  final IconData icon;

  const StoryTripOverviewStat({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class StoryTripOverviewViewModel extends ChangeNotifier {
  StoryTripOverviewViewModel({
    required this.tripId,
    TripSummaryService? tripSummaryService,
  }) : _tripSummaryService = tripSummaryService ?? TripSummaryService();

  final String tripId;
  final TripSummaryService _tripSummaryService;

  bool isLoading = false;
  String? errorMessage;

  List<StoryTripOverviewStat> stats = [];

  String _calculateTotalDuration(List<TripStop> stops) {
    final enteredTimes = stops
        .map((stop) => stop.enteredAt)
        .whereType<DateTime>()
        .toList();

    final exitedTimes = stops
        .map((stop) => stop.exitedAt)
        .whereType<DateTime>()
        .toList();

    if (enteredTimes.isEmpty || exitedTimes.isEmpty) {
      return 'N/A';
    }

    enteredTimes.sort();
    exitedTimes.sort();

    final firstEntered = enteredTimes.first;
    final lastExited = exitedTimes.last;

    final duration = lastExited.difference(firstEntered);

    if (duration.isNegative) {
      return 'N/A';
    }

    if (duration == Duration.zero) {
      return '0 min';
    }

    final days = duration.inDays;
    final hours = duration.inHours % 24;

    if (days > 0 && hours > 0) {
      return '$days day${days == 1 ? '' : 's'} '
          '$hours hr${hours == 1 ? '' : 's'}';
    } else if (days > 0) {
      return '$days day${days == 1 ? '' : 's'}';
    } else if (hours > 0) {
      return '$hours hr${hours == 1 ? '' : 's'}';
    } else {
      final minutes = duration.inMinutes;
      return '$minutes min${minutes == 1 ? '' : 's'}';
    }
  }

  double _calculateDistanceBetweenPoints(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(
      math.sqrt(a),
      math.sqrt(1 - a),
    );

    return earthRadiusKm * c;
  }

  double _calculateTotalDistance(List<TripStop> stops) {
    // Only use stops that have valid coordinates and an entry time.
    final validStops = stops
        .where(
          (stop) =>
              stop.latitude != null &&
              stop.longitude != null &&
              stop.enteredAt != null,
        )
        .toList();

    if (validStops.length < 2) {
      return 0;
    }

    // Make sure stops are chronological.
    validStops.sort(
      (a, b) => a.enteredAt!.compareTo(b.enteredAt!),
    );

    double totalDistance = 0;

    for (int i = 0; i < validStops.length - 1; i++) {
      final current = validStops[i];
      final next = validStops[i + 1];

      totalDistance += _calculateDistanceBetweenPoints(
        current.latitude!,
        current.longitude!,
        next.latitude!,
        next.longitude!,
      );
    }

    return totalDistance;
  }

  String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }

    return '${distanceKm.toStringAsFixed(1)} km';
  }

  Future<void> loadTripOverview() async {
    debugPrint('========== LOAD STORY TRIP OVERVIEW ==========');
    debugPrint('Trip ID: $tripId');

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final summary = await _tripSummaryService.getStoryData(tripId);

      final distinctLocations = summary.activities
          .map((a) => a.locationName)
          .where((name) => name != null && name.trim().isNotEmpty)
          .toSet();

      final totalDistance = _calculateTotalDistance(summary.stops);
      stats = [
        StoryTripOverviewStat(
          label: 'Days',
          value: _calculateTotalDuration(summary.stops),
          icon: Icons.calendar_month_rounded,
        ),
        StoryTripOverviewStat(
          label: 'Places',
          value: '${distinctLocations.length}',
          icon: Icons.location_on_rounded,
        ),
        StoryTripOverviewStat(
          label: 'Distance',
          value: _formatDistance(totalDistance),
          icon: Icons.route_rounded,
        ),
        StoryTripOverviewStat(
          label: 'Photos',
          value: '${summary.photos.length}',
          icon: Icons.photo_camera_rounded,
        ),
      ];

      debugPrint('TRIP OVERVIEW LOAD SUCCESS');

      for (final stat in stats) {
        debugPrint('${stat.label}: ${stat.value}');
      }
    } catch (error, stackTrace) {
      debugPrint('LOAD STORY TRIP OVERVIEW ERROR: $error');

      debugPrintStack(stackTrace: stackTrace);

      stats = [];

      final message = error.toString().toLowerCase();
      if (message.contains('socketexception') ||
          message.contains('connection refused') ||
          message.contains('network is unreachable') ||
          message.contains('failed host lookup') ||
          message.contains('timed out')) {
        errorMessage = 'Request failed. Please check your connection.';
      } else {
        errorMessage = 'Unable to load trip overview.';
      }
    } finally {
      isLoading = false;

      debugPrint('Trip overview stat count: ${stats.length}');
      debugPrint('==============================================');

      notifyListeners();
    }
  }
}