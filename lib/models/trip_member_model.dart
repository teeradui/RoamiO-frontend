class TripMember {
  final String participantId;
  final String tripId;
  final String userId;
  final String memberStatus;

  const TripMember({
    required this.participantId,
    required this.tripId,
    required this.userId,
    required this.memberStatus,
  });

  factory TripMember.fromJson(Map<String, dynamic> json) {
    return TripMember(
      participantId: json['participantId']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      memberStatus: json['memberStatus'] ?? '',
    );
  }
}

/*class TripMember {
  final String participantId;
  final String tripId;
  final String userId;
  final String username;
  final String? profileImageUrl;
  final String memberStatus;

  const TripMember({
    required this.participantId,
    required this.tripId,
    required this.userId,
    required this.username,
    required this.memberStatus,
    this.profileImageUrl,
  });

  factory TripMember.fromJson(Map<String, dynamic> json) {
    return TripMember(
      participantId:
          json['participantId']?.toString() ??
          json['participant_id']?.toString() ??
          '',
      tripId:
          json['tripId']?.toString() ??
          json['trip_id']?.toString() ??
          '',
      userId:
          json['userId']?.toString() ??
          json['user_id']?.toString() ??
          '',
      username:
          json['username']?.toString() ??
          'Unknown User',
      profileImageUrl:
          json['profileImageUrl']?.toString() ??
          json['profile_image_url']?.toString(),
      memberStatus:
          json['memberStatus']?.toString() ??
          json['member_status']?.toString() ??
          '',
    );
  }
}*/