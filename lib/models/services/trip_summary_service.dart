import 'dart:io';

import '../repository/trip_summary_repository.dart';
import '../trip_summary_model.dart';

class TripSummaryService {
  final TripSummaryRepository _repo;

  TripSummaryService({TripSummaryRepository? repository})
      : _repo = repository ?? TripSummaryRepository();

  Future<TripPhoto> uploadPhoto(String tripId, File photo) {
    return _repo.uploadPhoto(tripId, photo);
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

  Future<ActivityGraphData> getActivityGraphData(String tripId) {
    return _repo.getActivityGraphData(tripId);
  }

  Future<StoryData> getStoryData(String tripId) {
    return _repo.getStoryData(tripId);
  }
}