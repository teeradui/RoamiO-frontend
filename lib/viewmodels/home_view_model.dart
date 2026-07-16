import 'package:flutter/material.dart';
import 'package:roamio_frontend/models/services/trip_member_service.dart';
import 'package:roamio_frontend/models/services/trip_service.dart';
import 'package:roamio_frontend/models/trip_model.dart' as trip_model;
import 'package:roamio_frontend/viewmodels/trip_card_view_model.dart';

enum TripFilter { all, upcoming, active, completed }

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    TripService? tripService,
    TripMemberService? tripMemberService,
  }) : _tripService = tripService ?? TripService(),
       _tripMemberService = tripMemberService ?? TripMemberService();

  final TripService _tripService;
  final TripMemberService _tripMemberService;

  TripFilter selectedFilter = TripFilter.all;

  List<TripCardViewModel> trips = [];

  bool isLoading = false;
  String? errorMessage;

  static const List<String> _months = [
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

  TripStatus _fromModelStatus(trip_model.TripStatus status) {
    switch (status) {
      case trip_model.TripStatus.upcoming:
        return TripStatus.upcoming;

      case trip_model.TripStatus.active:
        return TripStatus.active;

      case trip_model.TripStatus.completed:
        return TripStatus.completed;
    }
  }

  Future<TripCardViewModel> _toCardViewModel(
    trip_model.Trip trip, {
    required bool forceRefresh,
  }) async {
    List<TripCardMember> members = [];

    try {
      final fetchedMembers = await _tripMemberService.getMembersByTrip(
        trip.id,
        forceRefresh: forceRefresh,
      );

      members = fetchedMembers.map((member) {
        return TripCardMember(
          userId: member.userId,
          username: 'User ${member.userId}',
          profileImageUrl: null,
        );
      }).toList();
    } catch (error, stackTrace) {
      debugPrint('LOAD MEMBERS FOR TRIP ${trip.id} ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      // ถ้าสมาชิกโหลดไม่ได้ ยังให้ Trip Card แสดงได้
      members = [];
    }

    return TripCardViewModel(
      tripId: trip.id,
      tripName: trip.tripName,
      tripDestination: trip.tripDestination?.trim().isNotEmpty == true
          ? trip.tripDestination!
          : 'Unknown destination',
      startDate: _formatDate(trip.startDate),
      photoCount: 0,
      placeCount: 0,
      status: _fromModelStatus(trip.tripStatus),
      imageUrl: trip.imageUrl,
      members: members,
    );
  }

  Future<void> loadTrips({bool forceRefresh = false}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      debugPrint('========== LOAD HOME TRIPS ==========');
      debugPrint('forceRefresh: $forceRefresh');

      final results = await Future.wait([
        _tripService.getUpcomingTrips(forceRefresh: forceRefresh),
        _tripService.getActiveTrips(forceRefresh: forceRefresh),
        _tripService.getCompletedTrips(forceRefresh: forceRefresh),
      ]);

      final allTrips = <trip_model.Trip>[
        ...results[0],
        ...results[1],
        ...results[2],
      ];

      debugPrint('HOME TRIP COUNT: ${allTrips.length}');

      for (final trip in allTrips) {
        debugPrint(
          'HOME TRIP: '
          'id=${trip.id}, '
          'name=${trip.tripName}, '
          'destination=${trip.tripDestination}, '
          'status=${trip.tripStatus}',
        );
      }

      trips = await Future.wait(
        allTrips.map(
          (trip) => _toCardViewModel(trip, forceRefresh: forceRefresh),
        ),
      );

      for (final trip in trips) {
        debugPrint(
          'TRIP CARD: '
          'tripId=${trip.tripId}, '
          'tripName=${trip.tripName}, '
          'destination=${trip.tripDestination}, '
        );
      }
    } catch (error, stackTrace) {
      debugPrint('LOAD HOME TRIPS ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage = 'Unable to load trips.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<TripCardViewModel> get upcomingActiveTrips {
    return trips.where((trip) {
      return trip.status == TripStatus.upcoming ||
          trip.status == TripStatus.active;
    }).toList();
  }

  List<TripCardViewModel> get completedTrips {
    return trips.where((trip) {
      return trip.status == TripStatus.completed;
    }).toList();
  }

  List<TripCardViewModel> get filteredTrips {
    switch (selectedFilter) {
      case TripFilter.all:
        return trips;

      case TripFilter.upcoming:
        return trips.where((trip) {
          return trip.status == TripStatus.upcoming;
        }).toList();

      case TripFilter.active:
        return trips.where((trip) {
          return trip.status == TripStatus.active;
        }).toList();

      case TripFilter.completed:
        return completedTrips;
    }
  }

  bool get hasFilteredTrips => filteredTrips.isNotEmpty;

  bool get hasUpcomingActiveTrips => upcomingActiveTrips.isNotEmpty;

  bool get hasCompletedTrips => completedTrips.isNotEmpty;

  void changeFilter(TripFilter filter) {
    if (selectedFilter == filter) return;

    selectedFilter = filter;
    notifyListeners();
  }
}
