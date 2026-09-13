import 'dart:io';

import '../repository/trip_summary_repository.dart';
import '../trip_summary_model.dart';

class TripSummaryService {
  final TripSummaryRepository _repo;

  TripSummaryService({TripSummaryRepository? repository})
    : _repo = repository ?? TripSummaryRepository();

  Future<TripPhoto> uploadPhoto(
    String tripId,
    File photo, {
    DateTime? capturedAt,
    String? locationName,
    double? latitude,
    double? longitude,
  }) {
    return _repo.uploadPhoto(
      tripId,
      photo,
      capturedAt: capturedAt,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<List<TripPhoto>> getPhotos(String tripId) {
    return _repo.getPhotos(tripId);
  }

  Future<List<TripAward>> getAwards(String tripId) {
    return _repo.getAwards(tripId);
  }

  Future<TripSummary> getSummary(String tripId) {
    return _repo.getSummary(tripId);
  }

  Future<ActivityGraphData> getActivityGraphData(
    String tripId, {
    String userId = '1',
  }) {
    return _repo.getActivityGraphData(tripId, userId: userId);
  }

  Future<StoryData> getStoryData(String tripId, {String userId = '1'}) {
    return _repo.getStoryData(tripId, userId: userId);
  }

  Future<ActivityGraphData> getActivityGraphDataByTrip(String tripId) {
    return _repo.getActivityGraphDataByTrip(tripId);
  }

  Future<void> deletePhoto(String tripId, String photoId) {
    return _repo.deletePhoto(tripId, photoId);
  }
}
