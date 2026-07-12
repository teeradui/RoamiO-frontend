import '../repository/tripMemberRepository.dart';
import '../tripMemberModel.dart';

class TripMemberService {
  final TripMemberRepository _repo;

  TripMemberService({TripMemberRepository? repository})
      : _repo = repository ?? TripMemberRepository();

  Future<List<TripMember>> getMembersByTrip(String tripId, {bool forceRefresh = false}) {
    return _repo.findByTrip(tripId, forceRefresh: forceRefresh);
  }

  Future<TripMember> updateMemberStatus(String tripId, String participantId, String memberStatus) {
    return _repo.updateStatus(tripId, participantId, memberStatus);
  }

  Future<void> removeMember(String tripId, String participantId) {
    return _repo.remove(tripId, participantId);
  }
}