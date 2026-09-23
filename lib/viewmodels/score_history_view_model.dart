import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

enum ScoreHistoryStatus {
  arrivedEarly,
  onTime,
  slightDelay,
  extendedDelay,
  ghost,
}

class ScoreHistoryItem {
  final String tripName;
  final DateTime tripDate;
  final ScoreHistoryStatus status;
  final int score;

  const ScoreHistoryItem({
    required this.tripName,
    required this.tripDate,
    required this.status,
    required this.score,
  });
}

class ScoreHistoryViewModel extends ChangeNotifier {
  final List<ScoreHistoryItem> _history = [
    ScoreHistoryItem(
      tripName: 'Chiang Mai Cafe Hopping',
      tripDate: DateTime(2026, 9, 18),
      status: ScoreHistoryStatus.onTime,
      score: 15,
    ),
    ScoreHistoryItem(
      tripName: 'Doi Suthep Adventure',
      tripDate: DateTime(2026, 9, 12),
      status: ScoreHistoryStatus.arrivedEarly,
      score: 25,
    ),
    ScoreHistoryItem(
      tripName: 'Weekend at Pai',
      tripDate: DateTime(2026, 9, 5),
      status: ScoreHistoryStatus.slightDelay,
      score: -10,
    ),
    ScoreHistoryItem(
      tripName: 'Mae Kampong Trip',
      tripDate: DateTime(2026, 8, 28),
      status: ScoreHistoryStatus.onTime,
      score: 15,
    ),
    ScoreHistoryItem(
      tripName: 'Chiang Rai Road Trip',
      tripDate: DateTime(2026, 8, 20),
      status: ScoreHistoryStatus.extendedDelay,
      score: -20,
    ),
    ScoreHistoryItem(
      tripName: 'Mountain View Trip',
      tripDate: DateTime(2026, 8, 14),
      status: ScoreHistoryStatus.ghost,
      score: -30,
    ),
  ];

  List<ScoreHistoryItem> get history => List.unmodifiable(_history);

  String getStatusText(ScoreHistoryStatus status) {
    switch (status) {
      case ScoreHistoryStatus.arrivedEarly:
        return 'Arrived early';

      case ScoreHistoryStatus.onTime:
        return 'On time';

      case ScoreHistoryStatus.slightDelay:
        return 'Slight delay';

      case ScoreHistoryStatus.extendedDelay:
        return 'Extended delay';

      case ScoreHistoryStatus.ghost:
        return 'Ghost';
    }
  }

  IconData getStatusIcon(ScoreHistoryStatus status) {
    switch (status) {
      case ScoreHistoryStatus.arrivedEarly:
        return MingCuteIcons.mgc_run_fill;

      case ScoreHistoryStatus.onTime:
        return MdiIcons.clockCheck;

      case ScoreHistoryStatus.slightDelay:
        return MdiIcons.clockRemove;

      case ScoreHistoryStatus.extendedDelay:
        return MdiIcons.alarmLight;

      case ScoreHistoryStatus.ghost:
        return TablerIcons.ghost2Filled;
    }
  }

  LinearGradient getStatusGradient(ScoreHistoryStatus status) {
    switch (status) {
      case ScoreHistoryStatus.arrivedEarly:
        return AppColors.arrivedEarlyGradient;

      case ScoreHistoryStatus.onTime:
        return AppColors.onTimeGradient;

      case ScoreHistoryStatus.slightDelay:
        return AppColors.slightDelayGradient;

      case ScoreHistoryStatus.extendedDelay:
        return AppColors.extendedDelayGradient;

      case ScoreHistoryStatus.ghost:
        return AppColors.ghostGradient;
    }
  }

  Color getStatusColor(ScoreHistoryStatus status) {
    switch (status) {
      case ScoreHistoryStatus.arrivedEarly:
        return AppColors.arrivedEarlyColor;

      case ScoreHistoryStatus.onTime:
        return AppColors.onTimeColor;

      case ScoreHistoryStatus.slightDelay:
        return AppColors.slightDelayColor;

      case ScoreHistoryStatus.extendedDelay:
        return AppColors.extendedDelayColor;

      case ScoreHistoryStatus.ghost:
        return AppColors.ghostColor;
    }
  }

  void setHistory(List<ScoreHistoryItem> history) {
    _history
      ..clear()
      ..addAll(history);

    notifyListeners();
  }
}