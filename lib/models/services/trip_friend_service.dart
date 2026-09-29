import '../repository/trip_friend_repository.dart';
import '../trip_friend_model.dart';

class TripFriendService {
  final TripFriendRepository _repo;

  TripFriendService({TripFriendRepository? repository})
      : _repo = repository ?? TripFriendRepository();

  Future<TripFriendRequest> sendRequest(String receiverId) {
    return _repo.sendRequest(receiverId);
  }

  Future<TripFriend> getFriendById(String friendId) {
    return _repo.getFriendById(friendId);
  }

  Future<TripFriendRequest> getRequestById(String requestId) {
    return _repo.getRequestById(requestId);
  }

  Future<List<TripFriend>> getAllFriends() {
    return _repo.getAllFriends();
  }

  Future<List<TripFriendRequest>> getAllRequests() {
    return _repo.getAllRequests();
  }

  Future<TripFriend> updateFriendStatus(String friendId, FriendStatus status) {
    return _repo.updateFriendStatus(friendId, status);
  }

  Future<TripFriendRequest> updateRequestStatus(String requestId, RequestStatus status) {
    return _repo.updateRequestStatus(requestId, status);
  }

  Future<List<RecommendedFriend>> getRecommendedFriends({int limit = 10,}) {
    return _repo.getRecommendedFriends(limit: limit);
  }

  Future<List<RecommendedFriend>> searchUsers(String query) {
    return _repo.searchUsers(query);
  }
}