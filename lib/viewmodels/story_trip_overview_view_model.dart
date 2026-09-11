import 'package:flutter/material.dart';
import 'package:roamio_frontend/models/services/trip_summary_service.dart';

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

  Future<void> loadTripOverview() async {
    debugPrint('========== LOAD STORY TRIP OVERVIEW ==========');
    debugPrint('Trip ID: $tripId');

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final summary = await _tripSummaryService.getSummary(tripId);

      final distinctLocations = summary.activities
          .map((a) => a.locationName)
          .where((name) => name != null && name.trim().isNotEmpty)
          .toSet();

      // WIP (need to implement): no trip date range or distance calc
      // exists server-side yet.
      stats = [
        const StoryTripOverviewStat(
          label: 'Days',
          value: 'WIP (need to implement)',
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