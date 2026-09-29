class TripAccount {
  const TripAccount({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.reliabilityScore,
    this.profilePicture,
  });

  final String userId;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final double reliabilityScore;
  final String? profilePicture;

  // NOTE: backend currently also returns `password` (bcrypt hash) in the
  // raw JSON response. Intentionally NOT parsed/exposed here — do not add
  // a password field to this model. Backend-side fix (excluding it from
  // the response) to be done later.

  factory TripAccount.fromJson(Map<String, dynamic> json) {
    return TripAccount(
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? json['first_name']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? json['last_name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      reliabilityScore: _parseDouble(json['reliabilityScore'] ?? json['reliability_score']) ?? 200,
      profilePicture: json['profilePicture']?.toString() ?? json['profile_picture_url']?.toString(),
    );
  }

  TripAccount copyWith({
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    double? reliabilityScore,
  }) {
    return TripAccount(
      userId: userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      reliabilityScore: reliabilityScore ?? this.reliabilityScore,
    );
  }
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}


enum ReliabilityAttendance { early, onTime, late, veryLate, missing }

ReliabilityAttendance _attendanceFromString(String? value) {
  switch (value) {
    case 'VeryEarly':
      return ReliabilityAttendance.early;
    case 'Early':
      return ReliabilityAttendance.early;
    case 'OnTime':
      return ReliabilityAttendance.onTime;
    case 'Late':
      return ReliabilityAttendance.late;
    case 'VeryLate':
      return ReliabilityAttendance.veryLate;
    case 'undecided':
      return ReliabilityAttendance.missing;
    case 'Missing':
    default:
      return ReliabilityAttendance.missing;
  }
}

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

class AccountTrip {
  const AccountTrip({
    required this.userId,
    required this.tripId,
    required this.tripName,
    required this.startTime,
    required this.attendance,
    required this.tripStatus
  });

  final String userId;
  final String tripId;
  final String tripName;
  final DateTime? startTime;
  final ReliabilityAttendance attendance;
  final TripStatus tripStatus;

  factory AccountTrip.fromJson(Map<String, dynamic> json) {
    return AccountTrip(
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? json['trip_id']?.toString() ?? '',
      tripName: json['tripName']?.toString() ?? json['trip_name']?.toString() ?? '',
      startTime: _parseDateTime(json['acStartTime'] ?? json['ac_start_time']),
      attendance: _attendanceFromString(json['attendance']?.toString()),
      tripStatus: tripStatusFromString(json['tripStatus']?.toString() ?? json['trip_status']?.toString()),
    );
  }
}

class LoginResult {
  const LoginResult({
    required this.account,
    required this.token,
  });

  final TripAccount account;
  final String token;

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      account: TripAccount.fromJson(json['account'] as Map<String, dynamic>),
      token: json['token']?.toString() ?? '',
    );
  }
}

class AccountAward {
  const AccountAward({
    required this.awardId,
    required this.tripId,
    required this.tripName,
    required this.awardName,
    this.awardDescription,
  });

  final String awardId;
  final String tripId;
  final String tripName;
  final String awardName;
  final String? awardDescription;

  factory AccountAward.fromJson(Map<String, dynamic> json) {
    return AccountAward(
      awardId: json['awardId']?.toString() ?? json['award_id']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? json['trip_id']?.toString() ?? '',
      tripName: json['tripName']?.toString() ?? json['trip_name']?.toString() ?? '',
      awardName: json['awardName']?.toString() ?? json['award_name']?.toString() ?? '',
      awardDescription: json['awardDescription']?.toString() ?? json['award_description']?.toString(),
    );
  }
}