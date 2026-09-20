import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/models/services/trip_service.dart';
import 'package:roamio_frontend/models/services/trip_member_service.dart';
import 'package:roamio_frontend/models/services/location_tracking_service.dart';
import 'package:roamio_frontend/models/trip_model.dart' as trip_model;
import 'dart:math' as math;
import 'package:roamio_frontend/models/services/trip_summary_service.dart';
import 'package:roamio_frontend/models/trip_summary_model.dart';

enum TripStatus { upcoming, active, completed }

TripStatus _fromModelStatus(trip_model.TripStatus status) {
  switch (status) {
    case trip_model.TripStatus.active:
      return TripStatus.active;
    case trip_model.TripStatus.completed:
      return TripStatus.completed;
    case trip_model.TripStatus.upcoming:
      return TripStatus.upcoming;
  }
}

class TripMember {
  final String username;
  final String? imageUrl;

  TripMember({required this.username, this.imageUrl});
}

enum TripDetailSection { overview, map, activities, photo, member }

class TripDetailViewModel extends ChangeNotifier {
  final String tripId;
  final TripService _tripService;
  final TripMemberService _tripMemberService;
  final LocationTrackingService _locationTrackingService;
  final TripSummaryService _tripSummaryService;

  double _calculateDistanceBetweenPoints(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(
      math.sqrt(a),
      math.sqrt(1 - a),
    );

    return earthRadiusKm * c;
  }

  double _calculateTotalDistance(List<TripStop> stops) {
    // Only use stops that have valid coordinates and an entry time.
    final validStops = stops
        .where(
          (stop) =>
              stop.latitude != null &&
              stop.longitude != null &&
              stop.enteredAt != null,
        )
        .toList();

    if (validStops.length < 2) {
      return 0;
    }

    // Make sure stops are chronological.
    validStops.sort(
      (a, b) => a.enteredAt!.compareTo(b.enteredAt!),
    );

    double totalDistance = 0;

    for (int i = 0; i < validStops.length - 1; i++) {
      final current = validStops[i];
      final next = validStops[i + 1];

      totalDistance += _calculateDistanceBetweenPoints(
        current.latitude!,
        current.longitude!,
        next.latitude!,
        next.longitude!,
      );
    }

    return totalDistance;
  }

  String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }

    return '${distanceKm.toStringAsFixed(1)} km';
  }


  TripDetailViewModel({
    required this.tripId,
    TripService? tripService,
    TripMemberService? tripMemberService,
    LocationTrackingService? locationTrackingService,
    TripSummaryService? tripSummaryService,
  }) : _tripService = tripService ?? TripService(),
       _tripMemberService = tripMemberService ?? TripMemberService(),
       _tripSummaryService = tripSummaryService ?? TripSummaryService(),
       // Defaults to the app-wide singleton — see LocationTrackingService's
       // class doc for why this can't be a fresh instance per screen.
       _locationTrackingService =
           locationTrackingService ?? LocationTrackingService();

  // TODO: no auth wired up yet (see memberSectionViewmodel.dart's identical
  // note) — hardcoded placeholder until a real signed-in user id exists.
  static const String _currentUserId = '1';

  String tripName = "";
  String destination = "";
  String? meetingPoint;
  String? imageUrl;
  String startDate = "";
  String endDate = "";
  String startTime = "";
  DateTime? tripStartDateTime;
  DateTime? tripEndDateTime;

  // TODO: no backend endpoint currently computes trip travel distance.
  // Left at 0.0 until one exists.
  double distanceKm = 0.0;

  TripStatus status = TripStatus.upcoming;

  List<TripMember> members = [];

  bool isLoading = false;

  bool isDeleting = false;
  bool isEnding = false;

  String? actionErrorMessage;

  bool get isProcessingAction => isDeleting || isEnding;
  String? errorMessage;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final localDate = date.toLocal();

    return '${localDate.day} '
        '${_months[localDate.month - 1]} '
        '${localDate.year}';
  }

  /// "14:05" -> "02:05 PM"
  String _formatTime(DateTime? time) {
    if (time == null) return '';

    final localTime = time.toLocal();

    final hour = localTime.hour;
    final minute = localTime.minute;

    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '${displayHour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> loadTrip({bool forceRefresh = false}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _tripService.getTripById(tripId, forceRefresh: forceRefresh),
        _tripMemberService.getMembersByTrip(tripId, forceRefresh: forceRefresh),
        _tripSummaryService.getSummary(tripId),
      ]);

      final trip = results[0] as trip_model.Trip;
      final fetchedMembers = results[1] as List;
      final summary = results[2] as TripSummary;

      tripName = trip.tripName;
      destination = trip.tripDestination ?? '';
      meetingPoint = trip.meetingPointName;
      imageUrl = trip.imageUrl;

      startDate = _formatDate(trip.startDate);
      endDate = _formatDate(trip.endDate);
      startTime = _formatTime(trip.startTime);
      status = _fromModelStatus(trip.tripStatus);
      distanceKm = _calculateTotalDistance(summary.stops);

      final startDateLocal = trip.startDate?.toLocal();
      final startTimeLocal = trip.startTime?.toLocal();

      if (startDateLocal != null && startTimeLocal != null) {
        tripStartDateTime = DateTime(
          startDateLocal.year,
          startDateLocal.month,
          startDateLocal.day,
          startTimeLocal.hour,
          startTimeLocal.minute,
        );
      }

      tripEndDateTime = trip.endDate?.toLocal();

      if (status == TripStatus.active) {
        _locationTrackingService.start(tripId, userId: _currentUserId);
      } else {
        await _locationTrackingService.stop();
      }

      members = fetchedMembers
          .map((member) => TripMember(username: member.userId))
          .toList();

      if (members.isEmpty && trip.createdBy.isNotEmpty) {
        members = [TripMember(username: trip.createdBy)];
      }
    } catch (error, stackTrace) {
      debugPrint('LOAD TRIP DETAIL ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage = "Unable to load trip details.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool get isUpcoming => status == TripStatus.upcoming;
  bool get isActive => status == TripStatus.active;
  bool get isCompleted => status == TripStatus.completed;

  String get statusText {
    switch (status) {
      case TripStatus.upcoming:
        return "Starts $startDate at $startTime";
      case TripStatus.active:
        return "Active";
      case TripStatus.completed:
        return "Completed";
    }
  }

  dynamic get statusIcon {
    switch (status) {
      case TripStatus.upcoming:
        return HugeIcons.strokeRoundedClock01;
      case TripStatus.active:
        return HugeIcons.strokeRoundedNavigation03;
      case TripStatus.completed:
        return HugeIcons.strokeRoundedCheckmarkCircle02;
    }
  }

  Color get statusColor {
    switch (status) {
      case TripStatus.upcoming:
        return AppColors.textUpcoming;
      case TripStatus.active:
        return AppColors.textActive;
      case TripStatus.completed:
        return AppColors.textCompleted;
    }
  }

  Color get statusBackgroundColor {
    switch (status) {
      case TripStatus.upcoming:
        return AppColors.bgUpcoming;

      case TripStatus.active:
        return AppColors.bgActive;

      case TripStatus.completed:
        return AppColors.bgCompleted;
    }
  }

  String get meetingPointText {
    return meetingPoint ?? "Didn't set the meeting point";
  }

  Future<bool> deleteTrip() async {
    if (isDeleting || isEnding) return false;

    isDeleting = true;
    actionErrorMessage = null;
    notifyListeners();

    try {
      await _tripService.deleteTrip(tripId);

      // กรณีลบทริปที่กำลัง Active ให้หยุด tracking ด้วย
      if (isActive) {
        await _locationTrackingService.stop();
      }

      return true;
    } catch (error, stackTrace) {
      debugPrint('DELETE TRIP ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      actionErrorMessage = "Unable to delete trip.";
      return false;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }

  Future<bool> endTrip() async {
    if (isDeleting || isEnding) return false;

    isEnding = true;
    actionErrorMessage = null;
    notifyListeners();

    try {
      await _tripService.updateTripStatus(
        tripId,
        trip_model.TripStatus.completed,
      );

      await _locationTrackingService.stop();

      // โหลดข้อมูล Trip ใหม่จาก backend ทันที
      await loadTrip(forceRefresh: true);

      return true;
    } catch (error, stackTrace) {
      debugPrint('END TRIP ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      actionErrorMessage = "Unable to end trip.";
      return false;
    } finally {
      isEnding = false;
      notifyListeners();
    }
  }

  void clearActionError() {
    actionErrorMessage = null;
    notifyListeners();
  }

  TripDetailSection selectedSection = TripDetailSection.overview;

  void selectSection(TripDetailSection section) {
    selectedSection = section;
    notifyListeners();
  }

  bool isSelectedSection(TripDetailSection section) {
    return selectedSection == section;
  }
}
