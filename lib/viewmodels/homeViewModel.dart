import 'package:flutter/material.dart';
import 'package:roamio_frontend/viewmodels/tripCardViewmodel.dart';

enum TripFilter {
  all,
  upcoming,
  active,
  completed,
}

class HomeViewModel extends ChangeNotifier {
  TripFilter selectedFilter = TripFilter.all;

  final List<TripCardViewModel> trips = [
    TripCardViewModel(
      tripName: "Japan Autumn Trip",
      startDate: "15 May 2026",
      photoCount: 32,
      placeCount: 8,
      status: TripStatus.upcoming,
      memberCount: 3,
    ),
    TripCardViewModel(
      tripName: "Chiang Mai Weekend Trip",
      startDate: "20 Jun 2026",
      photoCount: 10,
      placeCount: 4,
      status: TripStatus.active,
      memberCount: 2,
    ),
    TripCardViewModel(
      tripName: "Bangkok Food Trip",
      startDate: "02 Apr 2026",
      photoCount: 48,
      placeCount: 12,
      status: TripStatus.completed,
      memberCount: 4,
    ),
  ];

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