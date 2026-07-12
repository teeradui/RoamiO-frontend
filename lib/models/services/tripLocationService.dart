import '../repository/tripLocationRepository.dart';
import '../tripLocationModel.dart';

class TripLocationService {
  final TripLocationRepository _repo;

  TripLocationService({TripLocationRepository? repository})
      : _repo = repository ?? TripLocationRepository();

  Future<TripLocation> saveLocation(
    String tripId, {
    required String userId,
    required double latitude,
    required double longitude,
    DateTime? timestamp,
  }) {
    return _repo.save(
      tripId,
      userId: userId,
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
    );
  }

  Future<List<LatestMemberLocation>> getLatestLocations(String tripId) {
    return _repo.getLatest(tripId);
  }
}