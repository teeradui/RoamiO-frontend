/// Response for POST /trips/:tripId/location (matches LocationResponseDto)
class TripLocation {
  final String locationId;
  final String tripId;
  final String userId;
  final double latitude;
  final double longitude;
  final DateTime? timestamp;

  const TripLocation({
    required this.locationId,
    required this.tripId,
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.timestamp,
  });

  factory TripLocation.fromJson(Map<String, dynamic> json) {
    return TripLocation(
      locationId: json['locationId']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: json['timestamp'] != null ? DateTime.tryParse(json['timestamp']) : null,
    );
  }
}

/// Response for GET /trips/:tripId/location/latest (matches LatestLocationResponseDto)
class LatestMemberLocation {
  final String userId;
  final String? firstName;
  final String? lastName;
  final double latitude;
  final double longitude;
  final DateTime? timestamp;

  const LatestMemberLocation({
    required this.userId,
    this.firstName,
    this.lastName,
    required this.latitude,
    required this.longitude,
    this.timestamp,
  });

  factory LatestMemberLocation.fromJson(Map<String, dynamic> json) {
    return LatestMemberLocation(
      userId: json['userId']?.toString() ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: json['timestamp'] != null ? DateTime.tryParse(json['timestamp']) : null,
    );
  }
}