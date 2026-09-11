import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/models/services/trip_summary_service.dart';
import 'package:roamio_frontend/models/trip_summary_model.dart' as summary_model;

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
  StoryReliabilityScoresViewModel({
    required this.tripId,
    TripSummaryService? tripSummaryService,
  }) : _tripSummaryService = tripSummaryService ?? TripSummaryService();

  final String tripId;
  final TripSummaryService _tripSummaryService;

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

  ReliabilityArrivalStatus _statusFromAttendance(
    summary_model.ReliabilityAttendance attendance,
  ) {
    switch (attendance) {
      case summary_model.ReliabilityAttendance.early:
        return ReliabilityArrivalStatus.arrivedEarly;
      case summary_model.ReliabilityAttendance.onTime:
        return ReliabilityArrivalStatus.onTime;
      case summary_model.ReliabilityAttendance.late:
        return ReliabilityArrivalStatus.slightDelay;
      case summary_model.ReliabilityAttendance.veryLate:
        return ReliabilityArrivalStatus.extendedDelay;
      case summary_model.ReliabilityAttendance.missing:
        return ReliabilityArrivalStatus.ghost;
    }
  }

  int _scoreChangeForStatus(ReliabilityArrivalStatus status) {
    return rules.firstWhere((rule) => rule.status == status).scoreChange;
  }

  Future<void> loadReliabilityScores() async {
    debugPrint('========== LOAD STORY RELIABILITY SCORES ==========');
    debugPrint('Trip ID: $tripId');

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final storyData = await _tripSummaryService.getStoryData(tripId);

      members = storyData.reliabilityScores.map((entry) {
        final status = _statusFromAttendance(entry.attendance);

        return StoryReliabilityMember(
          userId: entry.userId,
          username: entry.username,
          arrivalStatus: status,
          scoreChange: _scoreChangeForStatus(status),
          currentScore: entry.currentScore.round(),
        );
      }).toList();

      debugPrint('RELIABILITY LOAD SUCCESS');
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

      final message = error.toString().toLowerCase();
      if (message.contains('socketexception') ||
          message.contains('connection refused') ||
          message.contains('network is unreachable') ||
          message.contains('failed host lookup') ||
          message.contains('timed out')) {
        errorMessage = 'Request failed. Please check your connection.';
      } else {
        errorMessage = 'Unable to load reliability scores.';
      }
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
