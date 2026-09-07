import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:roamio_frontend/theme/colors.dart';

enum ReliabilityArrivalStatus {
  arrivedEarly,
  onTime,
  slightDelay,
  extendedDelay,
  ghost,
}

class StoryReliabilityMember {
  final String userId;
  final String username;
  final String? profileImageUrl;

  final ReliabilityArrivalStatus arrivalStatus;

  final int scoreChange;
  final int currentScore;

  const StoryReliabilityMember({
    required this.userId,
    required this.username,
    required this.arrivalStatus,
    required this.scoreChange,
    required this.currentScore,
    this.profileImageUrl,
  });
}

class ReliabilityRuleItem {
  final ReliabilityArrivalStatus status;
  final String label;
  final int scoreChange;
  final String description;

  const ReliabilityRuleItem({
    required this.status,
    required this.label,
    required this.scoreChange,
    required this.description,
  });
}

class StoryReliabilityScoresViewModel extends ChangeNotifier {
  StoryReliabilityScoresViewModel({required this.tripId});

  final String tripId;

  static const int startingScore = 200;

  List<StoryReliabilityMember> members = [];

  bool isLoading = false;
  String? errorMessage;

  bool get hasMembers => members.isNotEmpty;

  final List<ReliabilityRuleItem> rules = const [
    ReliabilityRuleItem(
      status: ReliabilityArrivalStatus.arrivedEarly,
      label: 'Arrived Early',
      scoreChange: 25,
      description: 'More than 5 min before trip start.',
    ),
    ReliabilityRuleItem(
      status: ReliabilityArrivalStatus.onTime,
      label: 'On Time',
      scoreChange: 15,
      description: 'Within 5 min before or after trip start.',
    ),
    ReliabilityRuleItem(
      status: ReliabilityArrivalStatus.slightDelay,
      label: 'Slight Delay',
      scoreChange: -10,
      description: 'More than 5 min and up to 30 min late.',
    ),
    ReliabilityRuleItem(
      status: ReliabilityArrivalStatus.extendedDelay,
      label: 'Extended Delay',
      scoreChange: -20,
      description: 'More than 30 min after trip start.',
    ),
    ReliabilityRuleItem(
      status: ReliabilityArrivalStatus.ghost,
      label: 'Ghost',
      scoreChange: -30,
      description: 'Never detected at the meeting point.',
    ),
  ];

  Future<void> loadReliabilityScores() async {
    debugPrint('========== LOAD STORY RELIABILITY SCORES ==========');
    debugPrint('Trip ID: $tripId');

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      /*
       * TEMPORARY MOCK DATA
       *
       * TODO:
       * ภายหลังเปลี่ยนเป็นข้อมูลจาก backend
       * ซึ่ง backend จะคำนวณจาก attendance/tracking
       * ตอนเริ่ม Trip
       */

      members = const [
        StoryReliabilityMember(
          userId: '1',
          username: 'Teedy',
          arrivalStatus: ReliabilityArrivalStatus.arrivedEarly,
          scoreChange: 25,
          currentScore: 225,
        ),
        StoryReliabilityMember(
          userId: '2',
          username: 'Cherry',
          arrivalStatus: ReliabilityArrivalStatus.onTime,
          scoreChange: 15,
          currentScore: 215,
        ),
        StoryReliabilityMember(
          userId: '3',
          username: 'Sabrina',
          arrivalStatus: ReliabilityArrivalStatus.slightDelay,
          scoreChange: -10,
          currentScore: 190,
        ),
        StoryReliabilityMember(
          userId: '4',
          username: 'Pang',
          arrivalStatus: ReliabilityArrivalStatus.extendedDelay,
          scoreChange: -20,
          currentScore: 180,
        ),
        StoryReliabilityMember(
          userId: '5',
          username: 'Mint',
          arrivalStatus: ReliabilityArrivalStatus.ghost,
          scoreChange: -30,
          currentScore: 170,
        ),
      ];

      debugPrint('RELIABILITY MOCK LOAD SUCCESS');
      debugPrint('Member count: ${members.length}');

      for (final member in members) {
        debugPrint(
          '${member.username}: '
          '${getStatusLabel(member.arrivalStatus)}, '
          '${formatScoreChange(member.scoreChange)}, '
          'score=${member.currentScore}',
        );
      }
    } catch (error, stackTrace) {
      debugPrint('LOAD STORY RELIABILITY ERROR: $error');

      debugPrintStack(stackTrace: stackTrace);

      members = [];

      errorMessage = 'Unable to load reliability scores.';
    } finally {
      isLoading = false;

      debugPrint('=================================================');

      notifyListeners();
    }
  }

  String getStatusLabel(ReliabilityArrivalStatus status) {
    switch (status) {
      case ReliabilityArrivalStatus.arrivedEarly:
        return 'Arrived Early';

      case ReliabilityArrivalStatus.onTime:
        return 'On Time';

      case ReliabilityArrivalStatus.slightDelay:
        return 'Slight Delay';

      case ReliabilityArrivalStatus.extendedDelay:
        return 'Extended Delay';

      case ReliabilityArrivalStatus.ghost:
        return 'Ghost';
    }
  }

  IconData getStatusIcon(ReliabilityArrivalStatus status) {
    switch (status) {
      case ReliabilityArrivalStatus.arrivedEarly:
        return MingCuteIcons.mgc_run_fill;

      case ReliabilityArrivalStatus.onTime:
        return MdiIcons.clockCheck;

      case ReliabilityArrivalStatus.slightDelay:
        return MdiIcons.clockRemove;

      case ReliabilityArrivalStatus.extendedDelay:
        return MdiIcons.alarmLight;

      case ReliabilityArrivalStatus.ghost:
        return TablerIcons.ghost2Filled;
    }
  }

  LinearGradient getStatusGradient(ReliabilityArrivalStatus status) {
    switch (status) {
      case ReliabilityArrivalStatus.arrivedEarly:
        return AppColors.arrivedEarlyGradient;

      case ReliabilityArrivalStatus.onTime:
        return AppColors.onTimeGradient;

      case ReliabilityArrivalStatus.slightDelay:
        return AppColors.slightDelayGradient;

      case ReliabilityArrivalStatus.extendedDelay:
        return AppColors.extendedDelayGradient;

      case ReliabilityArrivalStatus.ghost:
        return AppColors.ghostGradient;
    }
  }

  Color getStatusColor(ReliabilityArrivalStatus status) {
    switch (status) {
      case ReliabilityArrivalStatus.arrivedEarly:
        return AppColors.arrivedEarlyColor;

      case ReliabilityArrivalStatus.onTime:
        return AppColors.onTimeColor;

      case ReliabilityArrivalStatus.slightDelay:
        return AppColors.slightDelayColor;

      case ReliabilityArrivalStatus.extendedDelay:
        return AppColors.extendedDelayColor;

      case ReliabilityArrivalStatus.ghost:
        return AppColors.ghostColor;
    }
  }

  Color getStatusBackgroundColor(ReliabilityArrivalStatus status) {
    switch (status) {
      case ReliabilityArrivalStatus.arrivedEarly:
        return AppColors.arrivedEarlyBackground;

      case ReliabilityArrivalStatus.onTime:
        return AppColors.onTimeBackground;

      case ReliabilityArrivalStatus.slightDelay:
        return AppColors.slightDelayBackground;

      case ReliabilityArrivalStatus.extendedDelay:
        return AppColors.extendedDelayBackground;

      case ReliabilityArrivalStatus.ghost:
        return AppColors.ghostBackground;
    }
  }

  Color getScoreColor(int score) {
    if (score >= startingScore) {
      return const Color(0xFF4BAE4F);
    }

    return const Color(0xFFE5484D);
  }

  IconData getScoreChangeIcon(int change) {
    if (change >= 0) {
      return Icons.trending_up_rounded;
    }

    return Icons.trending_down_rounded;
  }

  String formatScoreChange(int change) {
    if (change > 0) {
      return '+$change';
    }

    return '$change';
  }

  double getScoreProgress(int score) {
    // Mock UI scale: 0 - 300
    const maxScore = 300;

    final safeScore = score.clamp(0, maxScore);

    return safeScore / maxScore;
  }
}
