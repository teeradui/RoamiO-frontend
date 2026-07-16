class TripNotification {
  final String notificationId;
  final String userId;
  final String? tripId;
  final String? title;
  final String? message;
  final String? referenceId;
  final bool isRead;
  final DateTime? createdAt;

  const TripNotification({
    required this.notificationId,
    required this.userId,
    this.tripId,
    this.title,
    this.message,
    this.referenceId,
    this.isRead = false,
    this.createdAt,
  });

  factory TripNotification.fromJson(Map<String, dynamic> json) {
    return TripNotification(
      notificationId: json['notificationId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      tripId: json['tripId']?.toString(),
      title: json['title'],
      message: json['message'],
      referenceId: json['referenceId']?.toString(),
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'])?.toLocal() : null,
    );
  }
}