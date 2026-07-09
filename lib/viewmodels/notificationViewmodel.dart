import 'package:flutter/material.dart';

enum NotificationGroup { today, thisWeek, previous }

enum NotificationType { tripInvite, system, memberActivity }

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String timeText;
  final NotificationGroup group;
  final NotificationType type;

  final String? profileImageUrl;
  final String? username;

  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeText,
    required this.group,
    required this.type,
    this.profileImageUrl,
    this.username,
    this.isRead = false,
  });
}

class NotificationViewModel extends ChangeNotifier {
  final List<NotificationItem> notifications = [
    NotificationItem(
      id: "1",
      type: NotificationType.tripInvite,
      title: "Trip Invitation",
      message: "Teedy invited you to Japan Autumn Trip.",
      timeText: "5 min ago",
      group: NotificationGroup.today,
      username: "Teedy",
      isRead: true
    ),

    NotificationItem(
      id: "2",
      type: NotificationType.memberActivity,
      title: "Cherry joined your trip",
      message: "Cherry accepted your invitation.",
      timeText: "20 min ago",
      group: NotificationGroup.today,
      username: "Cherry",
      profileImageUrl: null,
    ),

    NotificationItem(
      id: "3",
      type: NotificationType.system,
      title: "Trip Started",
      message: "Your trip has started. GPS tracking is now active.",
      timeText: "1 hour ago",
      group: NotificationGroup.previous,
    ),
  ];

  bool get hasNotifications => notifications.isNotEmpty;

  int get notificationCount => notifications.length;

  String get notificationCountText {
    return "$notificationCount ${notificationCount == 1 ? 'notification' : 'notifications'}";
  }

  List<NotificationItem> byGroup(NotificationGroup group) {
    return notifications.where((item) => item.group == group).toList();
  }

  void clearAll() {
    notifications.clear();
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((item) => item.id == id);
    if (index == -1) return;

    notifications[index].isRead = true;
    notifyListeners();
  }

  void acceptInvite(String id) {
    notifications.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void rejectInvite(String id) {
    notifications.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
