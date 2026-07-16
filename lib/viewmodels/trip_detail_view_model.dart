import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/models/services/trip_service.dart';
import 'package:roamio_frontend/models/services/trip_member_service.dart';
import 'package:roamio_frontend/models/services/location_tracking_service.dart';
import 'package:roamio_frontend/models/trip_model.dart' as trip_model;

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

  TripDetailViewModel({
    required this.tripId,
    TripService? tripService,
    TripMemberService? tripMemberService,
    LocationTrackingService? locationTrackingService,
  }) : _tripService = tripService ?? TripService(),
       _tripMemberService = tripMemberService ?? TripMemberService(),
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

  String startDate = "";
  String endDate = "";
  String startTime = "";

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
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  /// "14:05" -> "02:05 PM"
  String _formatTime(String? time) {
    if (time == null || time.trim().isEmpty) return '';

    int? hour;
    int? minute;

    // กรณี Backend ส่ง Timestamp เต็ม
    final parsedDateTime = DateTime.tryParse(time);

    if (parsedDateTime != null) {
      final localTime = parsedDateTime.toLocal();
      hour = localTime.hour;
      minute = localTime.minute;
    } else {
      // กรณี Backend ส่งเฉพาะ HH:mm หรือ HH:mm:ss
      final parts = time.split(':');

      if (parts.length < 2) return time;

      hour = int.tryParse(parts[0]);
      minute = int.tryParse(parts[1]);
    }

    if (hour == null || minute == null) return time;

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
      ]);

      final trip = results[0] as trip_model.Trip;
      final fetchedMembers = results[1] as List;

      tripName = trip.tripName;
      destination = trip.tripDestination ?? '';
      meetingPoint = trip.meetingPointName;
      startDate = _formatDate(trip.startDate);
      endDate = _formatDate(trip.endDate);
      startTime = _formatTime(trip.startTime);
      status = _fromModelStatus(trip.tripStatus);

      // Location tracking should run for as long as the trip is Active —
      // this covers the case where the screen is (re)opened on a trip
      // that's already active (e.g. app restart), not just the endTrip
      // transition below.
      if (status == TripStatus.active) {
        _locationTrackingService.start(tripId, userId: _currentUserId);
      } else {
        _locationTrackingService.stop();
      }

      // NOTE: TripMemberResponseDto only exposes userId, not a display name
      // or avatar — there's no user-lookup endpoint yet to resolve either.
      // Falling back to userId as the label until one exists.
      members = fetchedMembers
          .map((m) => TripMember(username: m.userId))
          .toList();

      if (members.isEmpty && trip.createdBy.isNotEmpty) {
        members = [TripMember(username: trip.createdBy)];
      }
    } catch (e) {
      errorMessage = "Unable to load trip details.";
    }

    isLoading = false;
    notifyListeners();
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
      final updatedTrip = await _tripService.updateTripStatus(
        tripId,
        trip_model.TripStatus.completed,
      );

      status = _fromModelStatus(updatedTrip.tripStatus);

      await _locationTrackingService.stop();

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
