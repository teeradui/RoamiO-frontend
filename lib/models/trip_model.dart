enum TripStatus {
  upcoming,
  active,
  completed,
}

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
  const Trip({
    this.id = '',
    this.createdBy = '',
    required this.tripName,
    this.startDate,
    this.endDate,
    this.startTime,
    this.tripDestination,
    this.meetingPointName,
    this.meetingPointLat,
    this.meetingPointLon,
    this.imageUrl,
    this.tripStatus = TripStatus.upcoming,
  });

  final String id;
  final String createdBy;
  final String tripName;

  // ส่งเข้า PostgreSQL timestamptz
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? startTime;

  final String? tripDestination;
  final String? meetingPointName;
  final double? meetingPointLat;
  final double? meetingPointLon;
  final String? imageUrl;
  final TripStatus tripStatus;

  factory Trip.fromJson(Map<String, dynamic> json) {
    final latValue =
        json['meetingPointLat'] ??
        json['meeting_point_lat'];

    final lonValue =
        json['meetingPointLon'] ??
        json['meeting_point_lon'];

    return Trip(
      id:
          json['tripId']?.toString() ??
          json['trip_id']?.toString() ??
          '',

      createdBy:
          json['createdBy']?.toString() ??
          json['created_by']?.toString() ??
          '',

      tripName:
          json['tripName']?.toString() ??
          json['trip_name']?.toString() ??
          '',

      startDate: _parseDateTime(
        json['startDate'] ?? json['start_date'],
      ),

      endDate: _parseDateTime(
        json['endDate'] ?? json['end_date'],
      ),

      startTime: _parseDateTime(
        json['startTime'] ?? json['start_time'],
      ),

      tripDestination:
          json['tripDestination']?.toString() ??
          json['trip_destination']?.toString(),

      meetingPointName:
          json['meetingPointName']?.toString() ??
          json['meeting_point_name']?.toString(),

      meetingPointLat: _parseDouble(latValue),
      meetingPointLon: _parseDouble(lonValue),

      imageUrl:
          json['imageUrl']?.toString() ??
          json['image_url']?.toString(),

      tripStatus: tripStatusFromString(
        json['tripStatus']?.toString() ??
            json['trip_status']?.toString(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripName': tripName,

      // มี Z ต่อท้าย แสดงว่าเป็น UTC
      'startDate':
          startDate?.toUtc().toIso8601String(),

      'endDate':
          endDate?.toUtc().toIso8601String(),

      'startTime':
          startTime?.toUtc().toIso8601String(),

      'tripDestination': tripDestination,
      'meetingPointName': meetingPointName,
      'meetingPointLat': meetingPointLat,
      'meetingPointLon': meetingPointLon,
      'tripStatus': tripStatusToString(tripStatus),
    };
  }

  Trip copyWith({
    String? tripName,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? startTime,
    String? tripDestination,
    String? meetingPointName,
    double? meetingPointLat,
    double? meetingPointLon,
    String? imageUrl,
    TripStatus? tripStatus,
  }) {
    return Trip(
      id: id,
      createdBy: createdBy,
      tripName: tripName ?? this.tripName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      tripDestination:
          tripDestination ?? this.tripDestination,
      meetingPointName:
          meetingPointName ?? this.meetingPointName,
      meetingPointLat:
          meetingPointLat ?? this.meetingPointLat,
      meetingPointLon:
          meetingPointLon ?? this.meetingPointLon,
      imageUrl: imageUrl ?? this.imageUrl,
      tripStatus: tripStatus ?? this.tripStatus,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    if (text.isEmpty) return null;

    return DateTime.tryParse(text);
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }
}