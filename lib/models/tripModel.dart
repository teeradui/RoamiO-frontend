enum TripStatus { upcoming, active, completed }

TripStatus tripStatusFromString(String? value) {
  switch (value) {
    case 'Active':
      return TripStatus.active;
    case 'Completed':
      return TripStatus.completed;
    case 'Upcoming':
    default:
      return TripStatus.upcoming;
  }
}

String tripStatusToString(TripStatus status) {
  switch (status) {
    case TripStatus.active:
      return 'Active';
    case TripStatus.completed:
      return 'Completed';
    case TripStatus.upcoming:
      return 'Upcoming';
  }
}

class Trip {
  final String id;
  final String ownerId;
  final String tripName;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? startTime;
  final String? tripDestination;
  final String? meetingPoint;
  final String? imageUrl;
  final TripStatus tripStatus;

  const Trip({
    this.id = '',
    this.ownerId = '',
    required this.tripName,
    this.startDate,
    this.endDate,
    this.startTime,
    this.tripDestination,
    this.meetingPoint,
    this.imageUrl,
    this.tripStatus = TripStatus.upcoming,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      ownerId: json['owner_id']?.toString() ?? json['ownerId']?.toString() ?? '',
      tripName: json['trip_name'] ?? '',
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
      startTime: json['start_time'],
      tripDestination: json['trip_destination'],
      meetingPoint: json['meeting_point'],
      imageUrl: json['image_url'],
      tripStatus: tripStatusFromString(json['trip_status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_name': tripName,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'start_time': startTime,
      'trip_destination': tripDestination,
      'meeting_point': meetingPoint,
      'trip_status': tripStatusToString(tripStatus),
    };
  }

  Trip copyWith({
    String? tripName,
    DateTime? startDate,
    DateTime? endDate,
    String? startTime,
    String? tripDestination,
    String? meetingPoint,
    String? imageUrl,
    TripStatus? tripStatus,
  }) {
    return Trip(
      id: id,
      ownerId: ownerId,
      tripName: tripName ?? this.tripName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      tripDestination: tripDestination ?? this.tripDestination,
      meetingPoint: meetingPoint ?? this.meetingPoint,
      imageUrl: imageUrl ?? this.imageUrl,
      tripStatus: tripStatus ?? this.tripStatus,
    );
  }
}