import 'package:flutter/material.dart';
import 'package:roamio_frontend/viewmodels/tripCardViewmodel.dart';
import 'package:roamio_frontend/models/services/tripService.dart';
import 'package:roamio_frontend/models/tripModel.dart' as trip_model;

enum TripFilter {
  all,
  upcoming,
  active,
  completed,
}

class HomeViewModel extends ChangeNotifier {
  final TripService _tripService;

  HomeViewModel({TripService? tripService})
    : _tripService = tripService ?? TripService();

  TripFilter selectedFilter = TripFilter.all;
 
  List<TripCardViewModel> trips = [];

  bool isLoading = false;
  String? errorMessage;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
 
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }
 
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


  TripCardViewModel _toCardViewModel(trip_model.Trip trip) {
    return TripCardViewModel(
      tripId: trip.id,
      tripName: trip.tripName,
      startDate: _formatDate(trip.startDate),
      // TODO: no backend source for photo/place/member counts yet on the
      // trip-list endpoints. Defaulting to 0 until those exist; wiring
      // memberCount via a per-trip TripMemberService call was deliberately
      // skipped here to avoid an N+1 request per card in the list.
      photoCount: 0,
      placeCount: 0,
      memberCount: 0,
      status: _fromModelStatus(trip.tripStatus),
      imageUrl: trip.imageUrl,
    );
  }
 
  Future<void> loadTrips() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
 
    try {
      final results = await Future.wait([
        _tripService.getUpcomingTrips(),
        _tripService.getActiveTrips(),
        _tripService.getCompletedTrips(),
      ]);
 
      final allTrips = [
        ...results[0],
        ...results[1],
        ...results[2],
      ];
 
      trips = allTrips.map(_toCardViewModel).toList();
    } catch (e) {
      errorMessage = "Unable to load trips.";
    }
 
    isLoading = false;
    notifyListeners();
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
        return trips
            .where((trip) => trip.status == TripStatus.upcoming)
            .toList();

      case TripFilter.active:
        return trips
            .where((trip) => trip.status == TripStatus.active)
            .toList();

      case TripFilter.completed:
        return completedTrips;
    }
  }

  bool get hasFilteredTrips => filteredTrips.isNotEmpty;

  bool get hasUpcomingActiveTrips => upcomingActiveTrips.isNotEmpty;

  bool get hasCompletedTrips => completedTrips.isNotEmpty;

  void changeFilter(TripFilter filter) {
    selectedFilter = filter;
    notifyListeners();
  }
  
}