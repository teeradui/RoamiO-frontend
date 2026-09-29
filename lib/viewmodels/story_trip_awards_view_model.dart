import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:roamio_frontend/models/services/trip_summary_service.dart';
import 'package:roamio_frontend/models/services/auth_service.dart';
import 'package:roamio_frontend/models/trip_account_model.dart';
import 'package:roamio_frontend/models/services/trip_account_service.dart';
import 'package:roamio_frontend/models/trip_award_presets.dart';

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
    TripAccountService? tripAccountService,
  }) : _tripSummaryService = tripSummaryService ?? TripSummaryService(),
       _tripAccountService = tripAccountService ?? TripAccountService();

  final String tripId;
  final TripSummaryService _tripSummaryService;
  final TripAccountService _tripAccountService;

  String? _currentUserId;

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

  Future<void> loadTripAwards() async {
    debugPrint('========== LOAD STORY TRIP AWARDS ==========');
    debugPrint('Trip ID: $tripId');

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _currentUserId = await AuthService.instance.getCurrentUserId();

      final fetchedAwards = await _tripSummaryService.getAwards(tripId);

      // Look up each award-holder's account (username) in parallel.
      final uniqueUserIds = fetchedAwards
          .map((a) => a.userId)
          .whereType<String>()
          .toSet()
          .toList();

      final accountResults = await Future.wait(
        uniqueUserIds.map((userId) async {
          try {
            return await _tripAccountService.getAccountById(userId);
          } catch (error) {
            debugPrint('LOAD AWARD ACCOUNT ERROR ($userId): $error');
            return null;
          }
        }),
      );

      final accountsByUserId = <String, TripAccount>{};
      for (var i = 0; i < uniqueUserIds.length; i++) {
        final account = accountResults[i];
        if (account != null) {
          accountsByUserId[uniqueUserIds[i]] = account;
        }
      }

      awards = fetchedAwards.map((award) {
        final meta = awardMetaByName[award.awardName];

        if (meta == null) {
          debugPrint(
            'AWARD NAME NOT RECOGNIZED: "${award.awardName}" '
            '(no entry in _awardMetaByName — check for typo or new backend award)',
          );
        }

        final userId = award.userId ?? '';
        final account = accountsByUserId[userId];

        return StoryTripAward(
          userId: userId,
          username: account?.username ?? 'Unknown User',
          profileImageUrl: account?.profilePicture,
          type: meta?.type ?? TripAwardType.other,
          awardTitle: award.awardName,
          awardSubtitle: award.awardDescription,
          awardIcon: meta?.icon ?? Icons.emoji_events_rounded,
          isCurrentUser: userId == _currentUserId,
        );
      }).toList();

      debugPrint('TRIP AWARDS LOAD SUCCESS');
      debugPrint('Award count: ${awards.length}');

      for (final award in awards) {
        debugPrint(
          '${award.username} → '
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
}
