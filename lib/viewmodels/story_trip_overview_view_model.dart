import 'package:flutter/material.dart';

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
  });

  final String tripId;

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
      // TEMPORARY MOCK DATA
      // TODO: เปลี่ยนเป็นข้อมูลจาก backend ภายหลัง
      stats = const [
        StoryTripOverviewStat(
          label: 'Days',
          value: '3',
          icon: Icons.calendar_month_rounded,
        ),
        StoryTripOverviewStat(
          label: 'Places',
          value: '8',
          icon: Icons.location_on_rounded,
        ),
        StoryTripOverviewStat(
          label: 'Distance',
          value: '42.8 km',
          icon: Icons.route_rounded,
        ),
        StoryTripOverviewStat(
          label: 'Photos',
          value: '24',
          icon: Icons.photo_camera_rounded,
        ),
      ];

      debugPrint('TRIP OVERVIEW MOCK LOAD SUCCESS');

      for (final stat in stats) {
        debugPrint(
          '${stat.label}: ${stat.value}',
        );
      }
    } catch (error, stackTrace) {
      debugPrint(
        'LOAD STORY TRIP OVERVIEW ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      stats = [];

      errorMessage =
          'Unable to load trip overview.';
    } finally {
      isLoading = false;

      debugPrint(
        'Trip overview stat count: ${stats.length}',
      );
      debugPrint(
        '==============================================',
      );

      notifyListeners();
    }
  }
}