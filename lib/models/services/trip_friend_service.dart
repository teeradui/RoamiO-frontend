import '../repository/trip_friend_repository.dart';
import '../trip_friend_model.dart';

class TripFriendService {
  final TripFriendRepository _repo;

  TripFriendService({TripFriendRepository? repository})
      : _repo = repository ?? TripFriendRepository();

  Future<TripFriendRequest> sendRequest(String senderId, String receiverId) {
    return _repo.sendRequest(senderId, receiverId);
  }

  Future<TripFriend> getFriendById(String friendId) {
    return _repo.getFriendById(friendId);
  }

  Future<TripFriendRequest> getRequestById(String requestId) {
    return _repo.getRequestById(requestId);
  }

  Future<List<TripFriend>> getAllFriends(String userId) {
    return _repo.getAllFriends(userId);
  }

  Future<List<TripFriendRequest>> getAllRequests(String userId) {
    return _repo.getAllRequests(userId);
  }

  Future<TripFriend> updateFriendStatus(String friendId, FriendStatus status) {
    return _repo.updateFriendStatus(friendId, status);
  }

  Future<TripFriendRequest> updateRequestStatus(String requestId, RequestStatus status) {
    return _repo.updateRequestStatus(requestId, status);
  }
}