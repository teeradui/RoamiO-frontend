import 'dart:io';

import '../repository/tripRepository.dart';
import '../tripModel.dart';

class TripService {
  final TripRepository _repo;

  TripService({TripRepository? repository}) : _repo = repository ?? TripRepository();

  Future<Trip> createTrip(Trip trip, {File? image}) {
    return _repo.insert(trip, image);
  }

    Future<Trip> getTripById(String tripId, {bool forceRefresh = false}) {
    return _repo.findById(tripId, forceRefresh: forceRefresh);
  }

  Future<List<Trip>> getUpcomingTrips({bool forceRefresh = false}) {
    return _repo.findByStatus('Upcoming', forceRefresh: forceRefresh);
  }

  Future<List<Trip>> getActiveTrips({bool forceRefresh = false}) {
    return _repo.findByStatus('Active', forceRefresh: forceRefresh);
  }

  Future<List<Trip>> getCompletedTrips({bool forceRefresh = false}) {
    return _repo.findByStatus('Completed', forceRefresh: forceRefresh);
  }

  Future<Trip> updateTrip(String tripId, Map<String, dynamic> fields, {File? image}) {
    return _repo.update(tripId, fields, image: image);
  }

  Future<Trip> updateTripStatus(String tripId, TripStatus status) {
    return _repo.updateStatus(tripId, status);
  }

  Future<void> deleteTrip(String tripId) {
    return _repo.delete(tripId);
  }
}