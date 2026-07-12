class TripNotification {
  final String notificationId;
  final String userId;
  final String? tripId;
  final String? type;
  final String? message;
  final bool isRead;
  final DateTime? createdAt;

  const TripNotification({
    required this.notificationId,
    required this.userId,
    this.tripId,
    this.type,
    this.message,
    this.isRead = false,
    this.createdAt,
  });

  factory TripNotification.fromJson(Map<String, dynamic> json) {
    return TripNotification(
      notificationId: json['notificationId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      tripId: json['tripId']?.toString(),
      type: json['type'],
      message: json['message'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}