import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import 'package:roamio_frontend/models/trip_account_model.dart';
import 'package:roamio_frontend/models/services/trip_account_service.dart';
import 'package:roamio_frontend/models/services/auth_service.dart';

class ScoreHistoryViewModel extends ChangeNotifier {
  final String? userId;
  final TripAccountService _service = TripAccountService();

  ScoreHistoryViewModel({this.userId}) {
    loadHistory();
  }

  List<ScoreHistoryItem> _history = [];

  List<ScoreHistoryItem> get history => _history;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // If no userId is provided, retrieve the logged-in user's ID.
      final targetUserId =
          userId ?? await AuthService.instance.getCurrentUserId();

      if (targetUserId == null || targetUserId.isEmpty) {
        throw Exception('Unable to identify the user.');
      }

      _history = await _service.getScoreHistory(targetUserId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
}