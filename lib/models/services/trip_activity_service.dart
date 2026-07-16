import '../repository/trip_activity_repository.dart';
import '../trip_activity_model.dart';

class TripActivityService {
  final TripActivityRepository _repo;

  TripActivityService({TripActivityRepository? repository})
      : _repo = repository ?? TripActivityRepository();

  Future<List<TripActivity>> getTimeline(String tripId, {bool forceRefresh = false}) {
    return _repo.findTimelineByTrip(tripId, forceRefresh: forceRefresh);
  }
}