class TripActivity {
  final String activityId;
  final String tripId;
  final String userId;
  final String? locationName;
  final String? locationType;
  final String? activityType;
  final DateTime? startTime;
  final DateTime? endTime;
  final num? duration;

  const TripActivity({
    required this.activityId,
    required this.tripId,
    required this.userId,
    this.locationName,
    this.locationType,
    this.activityType,
    this.startTime,
    this.endTime,
    this.duration,
  });

  factory TripActivity.fromJson(Map<String, dynamic> json) {
    return TripActivity(
      activityId: json['activityId']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      locationName: json['locationName'],
      locationType: json['locationType'],
      activityType: json['activityType'],
      startTime: json['startTime'] != null ? DateTime.tryParse(json['startTime'])?.toLocal() : null,
      endTime: json['endTime'] != null ? DateTime.tryParse(json['endTime'])?.toLocal() : null,
      duration: json['duration'],
    );
  }
}