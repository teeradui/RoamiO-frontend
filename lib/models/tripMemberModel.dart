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