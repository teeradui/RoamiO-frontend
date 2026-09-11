class TripPhoto {
  const TripPhoto({
    required this.photoId,
    required this.tripId,
    this.userId,
    required this.photoUrl,
    this.uploadedAt,
  });

  final String photoId;
  final String tripId;
  final String? userId;
  final String photoUrl;
  final DateTime? uploadedAt;

  factory TripPhoto.fromJson(Map<String, dynamic> json) {
    return TripPhoto(
      photoId: json['photoId']?.toString() ?? json['photo_id']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? json['trip_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      photoUrl: json['photoUrl']?.toString() ?? json['photo_url']?.toString() ?? '',
      uploadedAt: _parseDateTime(json['uploadedAt'] ?? json['uploaded_at']),
    );
  }
}

class TripAward {
  const TripAward({
    required this.awardId,
    required this.tripId,
    this.userId,
    required this.awardName,
    this.awardDescription,
  });

  final String awardId;
  final String tripId;
  final String? userId;
  final String awardName;
  final String? awardDescription;

  factory TripAward.fromJson(Map<String, dynamic> json) {
    return TripAward(
      awardId: json['awardId']?.toString() ?? json['award_id']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? json['trip_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      awardName: json['awardName']?.toString() ?? json['award_name']?.toString() ?? '',
      awardDescription:
          json['awardDescription']?.toString() ?? json['award_description']?.toString(),
    );
  }
}

class TripSummaryTripInfo {
  const TripSummaryTripInfo({
    required this.tripId,
    required this.tripName,
    this.tripDestination,
  });

  final String tripId;
  final String tripName;
  final String? tripDestination;

  factory TripSummaryTripInfo.fromJson(Map<String, dynamic> json) {
    return TripSummaryTripInfo(
      tripId: json['tripId']?.toString() ?? json['trip_id']?.toString() ?? '',
      tripName: json['tripName']?.toString() ?? json['trip_name']?.toString() ?? '',
      tripDestination:
          json['tripDestination']?.toString() ?? json['trip_destination']?.toString(),
    );
  }
}

class TripSummaryMember {
  const TripSummaryMember({
    required this.participantId,
    required this.userId,
    this.attendance,
  });

  final String participantId;
  final String userId;
  final String? attendance;

  factory TripSummaryMember.fromJson(Map<String, dynamic> json) {
    return TripSummaryMember(
      participantId:
          json['participantId']?.toString() ?? json['participant_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      attendance: json['attendance']?.toString(),
    );
  }
}

class TripSummaryActivity {
  const TripSummaryActivity({
    required this.activityId,
    this.locationName,
    this.locationType,
    this.activityType,
    this.startTime,
    this.endTime,
  });

  final String activityId;
  final String? locationName;
  final String? locationType;
  final String? activityType;
  final DateTime? startTime;
  final DateTime? endTime;

  factory TripSummaryActivity.fromJson(Map<String, dynamic> json) {
    return TripSummaryActivity(
      activityId: json['activityId']?.toString() ?? json['activity_id']?.toString() ?? '',
      locationName: json['locationName']?.toString() ?? json['location_name']?.toString(),
      locationType: json['locationType']?.toString() ?? json['location_type']?.toString(),
      activityType: json['activityType']?.toString() ?? json['activity_type']?.toString(),
      startTime: _parseDateTime(json['acStartTime'] ?? json['ac_start_time']),
      endTime: _parseDateTime(json['acEndTime'] ?? json['ac_end_time']),
    );
  }
}

class TripStop {
  const TripStop({
    required this.stopId,
    this.latitude,
    this.longitude,
    this.enteredAt,
    this.exitedAt,
    this.locationName,
    this.locationType,
  });

  final String stopId;
  final double? latitude;
  final double? longitude;
  final DateTime? enteredAt;
  final DateTime? exitedAt;
  final String? locationName;
  final String? locationType;

  factory TripStop.fromJson(Map<String, dynamic> json) {
    return TripStop(
      stopId: json['stopId']?.toString() ?? json['stop_id']?.toString() ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      enteredAt: _parseDateTime(json['enteredAt'] ?? json['entered_at']),
      exitedAt: _parseDateTime(json['exitedAt'] ?? json['exited_at']),
      locationName: json['locationName']?.toString() ?? json['location_name']?.toString(),
      locationType: json['locationType']?.toString() ?? json['location_type']?.toString(),
    );
  }
}

class TripSummary {
  const TripSummary({
    required this.trips,
    required this.members,
    required this.activities,
    required this.awards,
    required this.stops,
    required this.photos,
  });

  final List<TripSummaryTripInfo> trips;
  final List<TripSummaryMember> members;
  final List<TripSummaryActivity> activities;
  final List<TripAward> awards;
  final List<TripStop> stops;
  final List<TripPhoto> photos;

  factory TripSummary.fromJson(Map<String, dynamic> json) {
    return TripSummary(
      trips: (json['trips'] as List? ?? [])
          .map((e) => TripSummaryTripInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      members: (json['members'] as List? ?? [])
          .map((e) => TripSummaryMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      activities: (json['activities'] as List? ?? [])
          .map((e) => TripSummaryActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
      awards: (json['awards'] as List? ?? [])
          .map((e) => TripAward.fromJson(e as Map<String, dynamic>))
          .toList(),
      stops: (json['stops'] as List? ?? [])
          .map((e) => TripStop.fromJson(e as Map<String, dynamic>))
          .toList(),
      photos: (json['photos'] as List? ?? [])
          .map((e) => TripPhoto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ActivityTypeCount {
  const ActivityTypeCount({required this.activityType, required this.count});

  final String activityType;
  final int count;

  factory ActivityTypeCount.fromJson(Map<String, dynamic> json) {
    return ActivityTypeCount(
      activityType: json['activityType']?.toString() ?? json['activity_type']?.toString() ?? '',
      count: json['count'] is int
          ? json['count'] as int
          : int.tryParse(json['count'].toString()) ?? 0,
    );
  }
}

class ActivityGraphData {
  const ActivityGraphData({
    required this.totalActivityTypes,
    required this.activityTypeCounts,
  });

  final int totalActivityTypes;
  final List<ActivityTypeCount> activityTypeCounts;

  factory ActivityGraphData.fromJson(Map<String, dynamic> json) {
    return ActivityGraphData(
      totalActivityTypes: json['totalActivityTypes'] is int
          ? json['totalActivityTypes'] as int
          : int.tryParse(json['totalActivityTypes'].toString()) ?? 0,
      activityTypeCounts: (json['activityTypeCounts'] as List? ?? [])
          .map((e) => ActivityTypeCount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Shape returned by getStoryData: spread of summary + photos/awards/activityTypeCounts.
class StoryData {
  const StoryData({
    required this.trips,
    required this.members,
    required this.activities,
    required this.stops,
    required this.awards,
    required this.photos,
    required this.activityTypeCounts,
    required this.reliabilityScores
  });

  final List<TripSummaryTripInfo> trips;
  final List<TripSummaryMember> members;
  final List<TripSummaryActivity> activities;
  final List<TripStop> stops;
  final List<TripAward> awards;
  final List<TripPhoto> photos;
  final List<ActivityTypeCount> activityTypeCounts;
  final List<TripMemberReliability> reliabilityScores;

  factory StoryData.fromJson(Map<String, dynamic> json) {
    return StoryData(
      trips: (json['trips'] as List? ?? [])
          .map((e) => TripSummaryTripInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      members: (json['members'] as List? ?? [])
          .map((e) => TripSummaryMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      activities: (json['activities'] as List? ?? [])
          .map((e) => TripSummaryActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
      stops: (json['stops'] as List? ?? [])
          .map((e) => TripStop.fromJson(e as Map<String, dynamic>))
          .toList(),
      awards: (json['awards'] as List? ?? [])
          .map((e) => TripAward.fromJson(e as Map<String, dynamic>))
          .toList(),
      photos: (json['photos'] as List? ?? [])
          .map((e) => TripPhoto.fromJson(e as Map<String, dynamic>))
          .toList(),
      activityTypeCounts: (json['activityTypeCounts'] as List? ?? [])
          .map((e) => ActivityTypeCount.fromJson(e as Map<String, dynamic>))
          .toList(),
      reliabilityScores: (json['tripMemberReliabilityScores'] as List? ?? [])
          .map((e) => TripMemberReliability.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

enum ReliabilityAttendance { early, onTime, late, veryLate, missing }

ReliabilityAttendance _attendanceFromString(String? value) {
  switch (value) {
    case 'Early':
      return ReliabilityAttendance.early;
    case 'OnTime':
      return ReliabilityAttendance.onTime;
    case 'Late':
      return ReliabilityAttendance.late;
    case 'VeryLate':
      return ReliabilityAttendance.veryLate;
    case 'Missing':
    default:
      return ReliabilityAttendance.missing;
  }
}

class TripMemberReliability {
  const TripMemberReliability({
    required this.userId,
    required this.username,
    required this.attendance,
    required this.currentScore,
  });

  final String userId;
  final String username;
  final ReliabilityAttendance attendance;
  final double currentScore;

  factory TripMemberReliability.fromJson(Map<String, dynamic> json) {
    return TripMemberReliability(
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      attendance: _attendanceFromString(
        json['attendance']?.toString(),
      ),
      currentScore: _parseDouble(json['reliabilityScore'] ?? json['reliability_score']) ?? 200,
    );
  }
}