class TripAccount {
  const TripAccount({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.reliabilityScore,
  });

  final String userId;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final double reliabilityScore;

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

class AccountTrip {
  const AccountTrip({
    required this.userId,
    required this.tripId,
    required this.tripName,
    required this.startTime,
    required this.attendance,
  });

  final String userId;
  final String tripId;
  final String tripName;
  final DateTime? startTime;
  final ReliabilityAttendance attendance;

  factory AccountTrip.fromJson(Map<String, dynamic> json) {
    return AccountTrip(
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? json['trip_id']?.toString() ?? '',
      tripName: json['tripName']?.toString() ?? json['trip_name']?.toString() ?? '',
      startTime: _parseDateTime(json['acStartTime'] ?? json['ac_start_time']),
      attendance: _attendanceFromString(json['attendance']?.toString()),
    );
  }
}