import 'dart:math';
import 'package:flutter/material.dart';
import 'package:roamio_frontend/viewmodels/overview_section_view_model.dart';

class StoryMyActivityHighlight {
  final String title;
  final String subtitle;
  final IconData icon;

  const StoryMyActivityHighlight({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class StoryMyActivityStatsViewModel extends ChangeNotifier {
  StoryMyActivityStatsViewModel({required this.tripId});

  final String tripId;

  bool isLoading = false;
  String? errorMessage;

  List<OverviewRadarItem> myActivityStats = [];

  StoryMyActivityHighlight? highlight;

  bool get hasStats => myActivityStats.isNotEmpty;

  StoryMyActivityHighlight? _getRandomHighlight(
  String activityType,
) {
  final options = _highlightOptions[activityType];

  if (options == null || options.isEmpty) {
    return null;
  }

  final seededRandom = Random(
    tripId.hashCode ^ activityType.hashCode,
  );

  return options[
    seededRandom.nextInt(options.length)
  ];
}

  final Map<String, List<StoryMyActivityHighlight>> _highlightOptions = {
    'Food': [
      const StoryMyActivityHighlight(
        title: 'You are the Food King!',
        subtitle: 'Your trip was basically a food tour!',
        icon: Icons.restaurant_rounded,
      ),
      const StoryMyActivityHighlight(
        title: 'Certified Foodie!',
        subtitle: 'You never missed a chance to eat!',
        icon: Icons.restaurant_rounded,
      ),
      const StoryMyActivityHighlight(
        title: 'Snack Attack Champion!',
        subtitle: 'Food stops were clearly your thing!',
        icon: Icons.fastfood_rounded,
      ),
      const StoryMyActivityHighlight(
        title: 'Taste Bud Traveler!',
        subtitle: 'You explored this trip one bite at a time!',
        icon: Icons.ramen_dining_rounded,
      ),
      const StoryMyActivityHighlight(
        title: 'Food Was the Destination!',
        subtitle: 'Every adventure deserves a good meal!',
        icon: Icons.local_dining_rounded,
      ),
    ],

    'Sightseeing': [
      const StoryMyActivityHighlight(
        title: 'Born to Explore!',
        subtitle: 'You were always looking for the next view!',
        icon: Icons.explore_rounded,
      ),
      const StoryMyActivityHighlight(
        title: 'Sightseeing Superstar!',
        subtitle: 'No landmark was safe from you!',
        icon: Icons.camera_alt_rounded,
      ),
      const StoryMyActivityHighlight(
        title: 'Adventure Seeker!',
        subtitle: 'You made the most of every stop!',
        icon: Icons.travel_explore_rounded,
      ),
      const StoryMyActivityHighlight(
        title: 'View Hunter!',
        subtitle: 'You found all the sights worth seeing!',
        icon: Icons.landscape_rounded,
      ),
      const StoryMyActivityHighlight(
        title: 'Explorer Mode: ON!',
        subtitle: 'You came to see it all!',
        icon: Icons.explore_rounded,
      ),
    ],

    'Accommodation': [
      const StoryMyActivityHighlight(
        title: 'Cozy Trip Champion!',
        subtitle: 'You knew when it was time to recharge!',
        icon: Icons.hotel_rounded,
      ),
      const StoryMyActivityHighlight(
        title: 'Rest & Recharge Pro!',
        subtitle: 'A great adventure needs great rest!',
        icon: Icons.bed_rounded,
      ),
      const StoryMyActivityHighlight(
        title: 'Cozy Mode: ON!',
        subtitle: 'Comfort was part of the adventure!',
        icon: Icons.bedtime_rounded,
      ),
      const StoryMyActivityHighlight(
        title: 'Master of Chill!',
        subtitle: 'You definitely knew how to slow things down!',
        icon: Icons.hotel_rounded,
      ),
    ],

    'Transit': [
      const StoryMyActivityHighlight(
        title: 'Always on the Move!',
        subtitle: 'You kept this adventure rolling!',
        icon: Icons.directions_rounded,
      ),
      const StoryMyActivityHighlight(
        title: 'Road Warrior!',
        subtitle: 'Getting there was half the adventure!',
        icon: Icons.route_rounded,
      ),
      const StoryMyActivityHighlight(
        title: 'Born to Roam!',
        subtitle: 'You were always heading somewhere new!',
        icon: Icons.navigation_rounded,
      ),
      const StoryMyActivityHighlight(
        title: 'Keep Moving!',
        subtitle: 'One stop was never enough for you!',
        icon: Icons.directions_car_rounded,
      ),
      const StoryMyActivityHighlight(
        title: 'Roaming Nonstop!',
        subtitle: 'You really put the roam in RoamiO!',
        icon: Icons.route_rounded,
      ),
    ],
  };


  Future<void> loadMyActivityStats() async {
    debugPrint('========== LOAD STORY MY ACTIVITY STATS ==========');
    debugPrint('Trip ID: $tripId');

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // TEMP MOCK DATA
      // TODO: เปลี่ยนเป็นข้อมูลจาก Overview/Backend ภายหลัง
      myActivityStats = const [
        OverviewRadarItem(label: 'Food', value: 9),
        OverviewRadarItem(label: 'Sightseeing', value: 6),
        OverviewRadarItem(label: 'Accommodation', value: 3),
        OverviewRadarItem(label: 'Transit', value: 5),
      ];

      if (myActivityStats.isNotEmpty) {
        final topActivity = myActivityStats.reduce(
          (current, next) => next.value > current.value ? next : current,
        );

        highlight = _getRandomHighlight(topActivity.label);
      }
    } catch (error, stackTrace) {
      debugPrint('LOAD STORY MY ACTIVITY STATS ERROR: $error');

      debugPrintStack(stackTrace: stackTrace);

      myActivityStats = [];
      highlight = null;

      errorMessage = 'Unable to load activity statistics.';
    } finally {
      isLoading = false;

      debugPrint('My activity stat count: ${myActivityStats.length}');
      debugPrint('===============================================');

      notifyListeners();
    }
  }
}
