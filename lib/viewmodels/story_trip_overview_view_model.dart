import 'package:flutter/material.dart';
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
    final timestamps = <DateTime>[];

    for (final stop in stops) {
      if (stop.enteredAt != null) timestamps.add(stop.enteredAt!);
      if (stop.exitedAt != null) timestamps.add(stop.exitedAt!);
    }

    if (timestamps.isEmpty) {
      return 'WIP (need to implement)';
    }

    timestamps.sort();

    final first = timestamps.first;
    final last = timestamps.last;
    final duration = last.difference(first);

    if (duration.isNegative || duration == Duration.zero) {
      return 'WIP (need to implement)';
    }

    final days = duration.inDays;
    final hours = duration.inHours % 24;

    if (days > 0 && hours > 0) {
      return '$days day${days == 1 ? '' : 's'} $hours hr${hours == 1 ? '' : 's'}';
    } else if (days > 0) {
      return '$days day${days == 1 ? '' : 's'}';
    } else if (hours > 0) {
      return '$hours hr${hours == 1 ? '' : 's'}';
    } else {
      final minutes = duration.inMinutes;
      return '$minutes min${minutes == 1 ? '' : 's'}';
    }
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

      // WIP (need to implement): no trip date range or distance calc
      // exists server-side yet.
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
        const StoryTripOverviewStat(
          label: 'Distance',
          value: 'WIP (need to implement)',
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