import '../repository/trip_invite_repository.dart';
import '../trip_invite_model.dart';

class TripInviteService {
  final TripInviteRepository _repo;

  TripInviteService({TripInviteRepository? repository})
      : _repo = repository ?? TripInviteRepository();

  Future<List<TripInvite>> getInvitesByTrip(String tripId, {bool forceRefresh = false}) {
    return _repo.findByTrip(tripId, forceRefresh: forceRefresh);
  }

  Future<TripInvite> sendInvite(String tripId, String userId) {
    return _repo.sendInvite(tripId, userId);
  }

  Future<TripInvite> respondToInvite(String tripId, String tripInviteId, InviteStatus status) {
    return _repo.respondToInvite(tripId, tripInviteId, status);
  }
}