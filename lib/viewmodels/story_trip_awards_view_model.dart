import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:roamio_frontend/models/services/trip_summary_service.dart';

enum TripAwardType {
  lateArrival,
  earlyArrival,
  food,
  sightseeing,
  accommodation,
  transit,
}

class _AwardMeta {
  final TripAwardType type;
  final IconData icon;
  const _AwardMeta(this.type, this.icon);
}

final Map<String, _AwardMeta> _awardMetaByName = {
  // lateArrival
  'Late Turtle': const _AwardMeta(TripAwardType.lateArrival, CupertinoIcons.tortoise_fill),
  'Fashionably Late': const _AwardMeta(TripAwardType.lateArrival, Icons.watch_later_rounded),
  'Last Minute Legend': const _AwardMeta(TripAwardType.lateArrival, Icons.timer_rounded),
  'Slow & Steady': const _AwardMeta(TripAwardType.lateArrival, Icons.directions_walk_rounded),

  // earlyArrival
  'Early Bird': const _AwardMeta(TripAwardType.earlyArrival, Icons.wb_sunny_rounded),
  'First on the Scene': const _AwardMeta(TripAwardType.earlyArrival, Icons.flag_rounded),
  'Ready, Set, Roam!': const _AwardMeta(TripAwardType.earlyArrival, Icons.rocket_launch_rounded),
  'Morning Hero': const _AwardMeta(TripAwardType.earlyArrival, Icons.light_mode_rounded),

  // food
  'Snack Commander': const _AwardMeta(TripAwardType.food, Icons.restaurant_rounded),
  'Foodie Supreme': const _AwardMeta(TripAwardType.food, Icons.ramen_dining_rounded),
  'Bite Boss': const _AwardMeta(TripAwardType.food, Icons.fastfood_rounded),
  'Taste Explorer': const _AwardMeta(TripAwardType.food, Icons.local_dining_rounded),

  // sightseeing
  'Explorer Mode': const _AwardMeta(TripAwardType.sightseeing, Icons.explore_rounded),
  'View Hunter': const _AwardMeta(TripAwardType.sightseeing, Icons.landscape_rounded),
  'Sightseeing Star': const _AwardMeta(TripAwardType.sightseeing, Icons.photo_camera_rounded),
  'Adventure Magnet': const _AwardMeta(TripAwardType.sightseeing, Icons.travel_explore_rounded),

  // accommodation
  'Cozy Commander': const _AwardMeta(TripAwardType.accommodation, Icons.hotel_rounded),
  'Rest Master': const _AwardMeta(TripAwardType.accommodation, Icons.bed_rounded),
  'Chill Champion': const _AwardMeta(TripAwardType.accommodation, Icons.night_shelter_rounded),
  'Recharge Pro': const _AwardMeta(TripAwardType.accommodation, Icons.bedtime_rounded),

  // transit
  'Road Warrior': const _AwardMeta(TripAwardType.transit, Icons.route_rounded),
  'Always on the Move': const _AwardMeta(TripAwardType.transit, Icons.directions_rounded),
  'Born to Roam': const _AwardMeta(TripAwardType.transit, Icons.navigation_rounded),
  'Transit Titan': const _AwardMeta(TripAwardType.transit, Icons.directions_bus_rounded),
};

class TripAwardPreset {
  final String title;
  final String subtitle;
  final IconData icon;

  const TripAwardPreset({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class StoryTripAward {
  final String userId;
  final String username;
  final String? profileImageUrl;

  final TripAwardType type;

  final String awardTitle;
  final String awardSubtitle;

  final IconData awardIcon;

  final bool isCurrentUser;

  const StoryTripAward({
    required this.userId,
    required this.username,
    required this.type,
    required this.awardTitle,
    required this.awardSubtitle,
    required this.awardIcon,
    this.profileImageUrl,
    this.isCurrentUser = false,
  });
}

class StoryTripAwardsViewModel extends ChangeNotifier {
  StoryTripAwardsViewModel({
    required this.tripId,
    TripSummaryService? tripSummaryService,
  }) : _tripSummaryService = tripSummaryService ?? TripSummaryService();

  final String tripId;
  final TripSummaryService _tripSummaryService;

  List<StoryTripAward> awards = [];

  bool isLoading = false;
  String? errorMessage;

  bool get hasAwards => awards.isNotEmpty;

  final Map<TripAwardType, List<TripAwardPreset>> _awardPresets = {
    TripAwardType.lateArrival: [
      TripAwardPreset(
        title: 'Late Turtle',
        subtitle: 'is the last one to join the adventure!',
        icon: CupertinoIcons.tortoise_fill,
      ),
      const TripAwardPreset(
        title: 'Fashionably Late',
        subtitle: 'made everyone wait for the grand entrance!',
        icon: Icons.watch_later_rounded,
      ),
      const TripAwardPreset(
        title: 'Last Minute Legend',
        subtitle: 'arrived just in time for the adventure!',
        icon: Icons.timer_rounded,
      ),
      const TripAwardPreset(
        title: 'Slow & Steady',
        subtitle: 'took the scenic route to the meeting point!',
        icon: Icons.directions_walk_rounded,
      ),
    ],

    TripAwardType.earlyArrival: [
      const TripAwardPreset(
        title: 'Early Bird',
        subtitle: 'was ready before everyone else!',
        icon: Icons.wb_sunny_rounded,
      ),
      const TripAwardPreset(
        title: 'First on the Scene',
        subtitle: 'beat everyone to the meeting point!',
        icon: Icons.flag_rounded,
      ),
      const TripAwardPreset(
        title: 'Ready, Set, Roam!',
        subtitle: 'was prepared before the adventure even began!',
        icon: Icons.rocket_launch_rounded,
      ),
      const TripAwardPreset(
        title: 'Morning Hero',
        subtitle: 'showed up bright and early!',
        icon: Icons.light_mode_rounded,
      ),
    ],

    TripAwardType.food: [
      const TripAwardPreset(
        title: 'Snack Commander',
        subtitle: 'never missed a food stop!',
        icon: Icons.restaurant_rounded,
      ),
      const TripAwardPreset(
        title: 'Foodie Supreme',
        subtitle: 'turned this trip into a tasting tour!',
        icon: Icons.ramen_dining_rounded,
      ),
      const TripAwardPreset(
        title: 'Bite Boss',
        subtitle: 'was always ready for the next bite!',
        icon: Icons.fastfood_rounded,
      ),
      const TripAwardPreset(
        title: 'Taste Explorer',
        subtitle: 'explored the trip one dish at a time!',
        icon: Icons.local_dining_rounded,
      ),
    ],

    TripAwardType.sightseeing: [
      const TripAwardPreset(
        title: 'Explorer Mode',
        subtitle: 'was always finding the next place!',
        icon: Icons.explore_rounded,
      ),
      const TripAwardPreset(
        title: 'View Hunter',
        subtitle: 'never let a good view go unnoticed!',
        icon: Icons.landscape_rounded,
      ),
      const TripAwardPreset(
        title: 'Sightseeing Star',
        subtitle: 'made every stop worth exploring!',
        icon: Icons.photo_camera_rounded,
      ),
      const TripAwardPreset(
        title: 'Adventure Magnet',
        subtitle: 'was always drawn to the next adventure!',
        icon: Icons.travel_explore_rounded,
      ),
    ],

    TripAwardType.accommodation: [
      const TripAwardPreset(
        title: 'Cozy Commander',
        subtitle: 'knew exactly when it was time to recharge!',
        icon: Icons.hotel_rounded,
      ),
      const TripAwardPreset(
        title: 'Rest Master',
        subtitle: 'made relaxation part of the adventure!',
        icon: Icons.bed_rounded,
      ),
      const TripAwardPreset(
        title: 'Chill Champion',
        subtitle: 'always found time to slow things down!',
        icon: Icons.night_shelter_rounded,
      ),
      const TripAwardPreset(
        title: 'Recharge Pro',
        subtitle: 'never underestimated the power of a good rest!',
        icon: Icons.bedtime_rounded,
      ),
    ],

    TripAwardType.transit: [
      const TripAwardPreset(
        title: 'Road Warrior',
        subtitle: 'kept the adventure moving!',
        icon: Icons.route_rounded,
      ),
      const TripAwardPreset(
        title: 'Always on the Move',
        subtitle: 'was never in one place for long!',
        icon: Icons.directions_rounded,
      ),
      const TripAwardPreset(
        title: 'Born to Roam',
        subtitle: 'really put the roam in RoamiO!',
        icon: Icons.navigation_rounded,
      ),
      const TripAwardPreset(
        title: 'Transit Titan',
        subtitle: 'spent the trip going places!',
        icon: Icons.directions_bus_rounded,
      ),
    ],
  };

  TripAwardPreset _getAwardPreset({
    required TripAwardType type,
    required String userId,
  }) {
    final options = _awardPresets[type]!;

    final seed = Object.hash(tripId, type.name, userId);

    final random = Random(seed);

    return options[random.nextInt(options.length)];
  }

  StoryTripAward _createAward({
    required String userId,
    required String username,
    required TripAwardType type,
    String? profileImageUrl,
    bool isCurrentUser = false,
  }) {
    final preset = _getAwardPreset(type: type, userId: userId);

    return StoryTripAward(
      userId: userId,
      username: username,
      type: type,
      awardTitle: preset.title,
      awardSubtitle: preset.subtitle,
      awardIcon: preset.icon,
      profileImageUrl: profileImageUrl,
      isCurrentUser: isCurrentUser,
    );
  }

    Future<void> loadTripAwards() async {
    debugPrint('========== LOAD STORY TRIP AWARDS ==========');
    debugPrint('Trip ID: $tripId');

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final fetchedAwards = await _tripSummaryService.getAwards(tripId);

      // WIP (need to implement): backend does not yet return username
      // for each award (Award only stores user_id). Also hardcoding
      // isCurrentUser check to userId == '1' until real auth/current
      // user id is wired in.
      awards = fetchedAwards.map((award) {
        final meta = _awardMetaByName[award.awardName];

        return StoryTripAward(
          userId: award.userId ?? '',
          username: 'WIP (need to implement)',
          type: meta?.type ?? TripAwardType.sightseeing,
          awardTitle: award.awardName,
          awardSubtitle: award.awardDescription ?? 'WIP (need to implement)',
          awardIcon: meta?.icon ?? Icons.emoji_events_rounded,
          isCurrentUser: award.userId == '1',
        );
      }).toList();

      debugPrint('TRIP AWARDS LOAD SUCCESS');
      debugPrint('Award count: ${awards.length}');

      for (final award in awards) {
        debugPrint(
          '${award.userId} → '
          '${award.awardTitle} '
          '(${award.type})',
        );
      }
    } catch (error, stackTrace) {
      debugPrint('LOAD STORY TRIP AWARDS ERROR: $error');

      debugPrintStack(stackTrace: stackTrace);

      awards = [];

      final message = error.toString().toLowerCase();
      if (message.contains('socketexception') ||
          message.contains('connection refused') ||
          message.contains('network is unreachable') ||
          message.contains('failed host lookup') ||
          message.contains('timed out')) {
        errorMessage = 'Request failed. Please check your connection.';
      } else {
        errorMessage = 'Unable to load trip awards.';
      }
    } finally {
      isLoading = false;

      debugPrint('===========================================');

      notifyListeners();
    }
  }

  Color getAwardColor(TripAwardType type) {
    switch (type) {
      case TripAwardType.lateArrival:
        return const Color(0xFFF7630D);

      case TripAwardType.earlyArrival:
        return const Color(0xFFECA205);

      case TripAwardType.food:
        return const Color(0xFFFF8340);

      case TripAwardType.sightseeing:
        return const Color(0xFF36A1C7);

      case TripAwardType.accommodation:
        return const Color(0xFF8E5CF7);

      case TripAwardType.transit:
        return const Color(0xFF2D7DFB);
    }
  }

  Color getAwardBackgroundColor(TripAwardType type) {
    switch (type) {
      case TripAwardType.lateArrival:
        return const Color(0x30FF7D5C);

      case TripAwardType.earlyArrival:
        return const Color(0x3BFFE37A);

      case TripAwardType.food:
        return const Color(0x30FFD3BB);

      case TripAwardType.sightseeing:
        return const Color(0x2636A1C7);

      case TripAwardType.accommodation:
        return const Color(0x268E5CF7);

      case TripAwardType.transit:
        return const Color(0x262D7DFB);
    }
  }
}
