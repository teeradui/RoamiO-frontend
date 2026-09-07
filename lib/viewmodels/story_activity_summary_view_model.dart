import 'package:flutter/material.dart';

enum StoryActivityType {
  food,
  sightseeing,
  accommodation,
  transit,
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
  });

  final String tripId;

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
        return next.count > current.count
            ? next
            : current;
      },
    );
  }

  bool get hasActivities => activityStats.isNotEmpty;

  Future<void> loadActivitySummary() async {
    debugPrint(
      '========== LOAD STORY ACTIVITY SUMMARY ==========',
    );
    debugPrint('Trip ID: $tripId');

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // TEMP MOCK DATA
      // TODO: ต่อ TripActivityService / backend ภายหลัง
      activityStats = const [
        StoryActivityStat(
          type: StoryActivityType.food,
          label: 'Food',
          count: 5,
          icon: Icons.restaurant_rounded,
        ),
        StoryActivityStat(
          type: StoryActivityType.sightseeing,
          label: 'Sightseeing',
          count: 8,
          icon: Icons.photo_camera_rounded,
        ),
        StoryActivityStat(
          type: StoryActivityType.accommodation,
          label: 'Accommodation',
          count: 2,
          icon: Icons.hotel_rounded,
        ),
        StoryActivityStat(
          type: StoryActivityType.transit,
          label: 'Transit',
          count: 4,
          icon: Icons.directions_car_rounded,
        ),
      ];

      debugPrint(
        'ACTIVITY SUMMARY MOCK LOAD SUCCESS',
      );
      debugPrint(
        'Total activities: $totalActivities',
      );
      debugPrint(
        'Most activity: ${mostActivity?.label} (${mostActivity?.count})',
      );

      for (final activity in activityStats) {
        debugPrint(
          '${activity.label}: ${activity.count}',
        );
      }
    } catch (error, stackTrace) {
      debugPrint(
        'LOAD STORY ACTIVITY SUMMARY ERROR: $error',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );

      activityStats = [];
      errorMessage =
          'Unable to load activity summary.';
    } finally {
      isLoading = false;

      debugPrint(
        'Activity type count: ${activityStats.length}',
      );
      debugPrint(
        '===============================================',
      );

      notifyListeners();
    }
  }

  Color getTextColor(
    StoryActivityType type,
  ) {
    switch (type) {
      case StoryActivityType.food:
        return const Color(0xFFECA205);

      case StoryActivityType.sightseeing:
        return const Color(0xFFF7630D);

      case StoryActivityType.accommodation:
        return const Color(0xFF8E5CF7);

      case StoryActivityType.transit:
        return const Color(0xFF36A1C7);
    }
  }

  Color getBackgroundColor(
    StoryActivityType type,
  ) {
    switch (type) {
      case StoryActivityType.food:
        return const Color(0x3BFFE37A);

      case StoryActivityType.sightseeing:
        return const Color(0x30FF7D5C);

      case StoryActivityType.accommodation:
        return const Color(0x268E5CF7);

      case StoryActivityType.transit:
        return const Color(0x2636A1C7);
    }
  }
}