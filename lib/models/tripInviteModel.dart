enum InviteStatus { pending, accept, reject, cancelled }

InviteStatus inviteStatusFromString(String? value) {
  switch (value) {
    case 'Accept':
      return InviteStatus.accept;
    case 'Reject':
      return InviteStatus.reject;
    case 'Cancelled':
      return InviteStatus.cancelled;
    case 'Pending':
    default:
      return InviteStatus.pending;
  }
}

String inviteStatusToString(InviteStatus status) {
  switch (status) {
    case InviteStatus.accept:
      return 'Accept';
    case InviteStatus.reject:
      return 'Reject';
    case InviteStatus.cancelled:
      return 'Cancelled';
    case InviteStatus.pending:
      return 'Pending';
  }
}

class TripInvite {
  final String tripInviteId;
  final String tripId;
  final String userId;
  final InviteStatus inviteStatus;

  const TripInvite({
    required this.tripInviteId,
    required this.tripId,
    required this.userId,
    required this.inviteStatus,
  });

  factory TripInvite.fromJson(Map<String, dynamic> json) {
    return TripInvite(
      tripInviteId: json['tripInviteId']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      inviteStatus: inviteStatusFromString(json['inviteStatus']),
    );
  }
}