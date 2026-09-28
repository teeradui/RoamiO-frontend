enum FriendStatus { friend, notFriend, undecided }

FriendStatus friendStatusFromString(String? value) {
  switch (value) {
    case 'friend':
      return FriendStatus.friend;
    case 'not_friend':
      return FriendStatus.notFriend;
    case 'undecided':
    default:
      return FriendStatus.undecided;
  }
}

String friendStatusToString(FriendStatus status) {
  switch (status) {
    case FriendStatus.friend:
      return 'friend';
    case FriendStatus.notFriend:
      return 'not_friend';
    case FriendStatus.undecided:
      return 'undecided';
  }
}

enum RequestStatus { accepted, denied, undecided }

RequestStatus requestStatusFromString(String? value) {
  switch (value) {
    case 'accepted':
      return RequestStatus.accepted;
    case 'denied':
      return RequestStatus.denied;
    case 'undecided':
    default:
      return RequestStatus.undecided;
  }
}

String requestStatusToString(RequestStatus status) {
  switch (status) {
    case RequestStatus.accepted:
      return 'accepted';
    case RequestStatus.denied:
      return 'denied';
    case RequestStatus.undecided:
      return 'undecided';
  }
}

class TripFriend {
  const TripFriend({
    required this.friendId,
    required this.userId,
    required this.friendUserId,
    required this.friendStatus,
  });

  final String friendId;
  final String userId;
  final String friendUserId;
  final FriendStatus friendStatus;

  factory TripFriend.fromJson(Map<String, dynamic> json) {
    return TripFriend(
      friendId: json['friendId']?.toString() ?? json['friend_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      friendUserId: json['friendUserId']?.toString() ?? json['friend_user_id']?.toString() ?? '',
      friendStatus: friendStatusFromString(
        json['friendStatus']?.toString() ?? json['friend_status']?.toString(),
      ),
    );
  }
}

class TripFriendRequest {
  const TripFriendRequest({
    required this.requestId,
    required this.senderId,
    required this.receiverId,
    required this.requestStatus,
  });

  final String requestId;
  final String senderId;
  final String receiverId;
  final RequestStatus requestStatus;

  factory TripFriendRequest.fromJson(Map<String, dynamic> json) {
    return TripFriendRequest(
      requestId: json['requestId']?.toString() ?? json['request_id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? json['sender_id']?.toString() ?? '',
      receiverId: json['receiverId']?.toString() ?? json['receiver_id']?.toString() ?? '',
      requestStatus: requestStatusFromString(
        json['requestStatus']?.toString() ?? json['request_status']?.toString(),
      ),
    );
  }
}