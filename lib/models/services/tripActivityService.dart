import '../repository/tripActivityRepository.dart';
import '../tripActivityModel.dart';

class TripActivityService {
  final TripActivityRepository _repo;

  TripActivityService({TripActivityRepository? repository})
      : _repo = repository ?? TripActivityRepository();

  Future<List<TripActivity>> getTimeline(String tripId, {bool forceRefresh = false}) {
    return _repo.findTimelineByTrip(tripId, forceRefresh: forceRefresh);
  }
}