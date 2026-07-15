import 'package:flutter/material.dart';
import 'package:roamio_frontend/models/services/tripNotificationService.dart';
import 'package:roamio_frontend/models/services/tripInviteService.dart';
import 'package:roamio_frontend/models/tripInviteModel.dart';
import 'package:roamio_frontend/models/tripNotificationModel.dart';

enum NotificationGroup { today, thisWeek, previous }

enum NotificationType { tripInvite, system, memberActivity }

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String timeText;
  final NotificationGroup group;
  final NotificationType type;
  final String? tripId;
  final String? referenceId;
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
    this.tripId,
    this.referenceId,
    this.profileImageUrl,
    this.username,
    this.isRead = false,
  });
}

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _notificationService;
  final TripInviteService _tripInviteService;

  NotificationViewModel({
    NotificationService? notificationService,
    TripInviteService? tripInviteService,
  })  : _notificationService = notificationService ?? NotificationService(),
        _tripInviteService = tripInviteService ?? TripInviteService();

  // TODO: no auth wired up yet (see memberSectionViewmodel.dart's identical
  // note) — there's no real signed-in user id available client-side.
  // Hardcoded placeholder until auth exists.
  static const String _currentUserId = '1';

  List<NotificationItem> notifications = [];

  bool isLoading = false;
  String? errorMessage;

  bool get hasNotifications => notifications.isNotEmpty;

  int get notificationCount => notifications.length;

  String get notificationCountText {
    return "$notificationCount ${notificationCount == 1 ? 'notification' : 'notifications'}";
  }

  List<NotificationItem> byGroup(NotificationGroup group) {
    return notifications.where((item) => item.group == group).toList();
  }

  NotificationType _mapType(String? title) {
    switch (title) {
      case 'TripInvite':
        return NotificationType.tripInvite;
      case 'MemberJoined':
      case 'MemberActivity':
        return NotificationType.memberActivity;
      case 'TripStarted':
      default:
        return NotificationType.system;
    }
  }

  String _displayTitle(String? backendTitle, NotificationType type) {
    switch (type) {
      case NotificationType.tripInvite:
        return "Trip Invitation";
      case NotificationType.memberActivity:
        return "Trip Update";
      case NotificationType.system:
        return "Notification";
    }
  }

  NotificationGroup _deriveGroup(DateTime? createdAt) {
    if (createdAt == null) return NotificationGroup.previous;

    final now = DateTime.now();
    final isToday = createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
    if (isToday) return NotificationGroup.today;

    final daysSince = now.difference(createdAt).inDays;
    if (daysSince <= 7) return NotificationGroup.thisWeek;

    return NotificationGroup.previous;
  }

  String _formatTimeAgo(DateTime? createdAt) {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }

  NotificationItem _toItem(TripNotification n) {
    final type = _mapType(n.title);
    return NotificationItem(
      id: n.notificationId,
      title: _displayTitle(n.title, type),
      message: n.message ?? '',
      timeText: _formatTimeAgo(n.createdAt),
      group: _deriveGroup(n.createdAt),
      type: type,
      tripId: n.tripId,
      referenceId: n.referenceId,
      isRead: n.isRead,
    );
  }

  Future<void> loadNotifications() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _notificationService.getNotifications(_currentUserId);
      notifications = fetched.map(_toItem).toList();
    } catch (e) {
      errorMessage = "Unable to load notifications.";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> clearAll() async {
    final previous = notifications;
    notifications = [];
    notifyListeners();

    try {
      for (final item in previous) {
        await _notificationService.deleteNotification(_currentUserId, item.id);
      }
    } catch (e) {

      errorMessage = "Some notifications could not be cleared.";
      await loadNotifications();
    }
  }

  Future<void> deleteNotification(String id) async {
    final previous = notifications;
    notifications = notifications.where((n) => n.id != id).toList();
    notifyListeners();

    try {
      await _notificationService.deleteNotification(_currentUserId, id);
    } catch (e) {
      notifications = previous;
      errorMessage = "Unable to delete notification.";
      notifyListeners();
    }
  }

  // Not routed yet hehe
  void markAsRead(String id) {
    final index = notifications.indexWhere((item) => item.id == id);
    if (index == -1) return;

    notifications[index].isRead = true;
    notifyListeners();
  }

  Future<void> updateInviteStatus(String notificationId, InviteStatus status) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    final notification = notifications[index];
    final tripId = notification.tripId;
    final tripInviteId = notification.referenceId;

    if (tripId == null || tripInviteId == null) {
      errorMessage = "This notification isn't linked to an invite.";
      notifyListeners();
      return;
    }

    final previous = notifications;
    // Optimistically remove the notification — it's been actioned either way.
    notifications = notifications.where((n) => n.id != notificationId).toList();
    notifyListeners();

    try {
      await _tripInviteService.respondToInvite(tripId, tripInviteId, status);
    } catch (e) {
      notifications = previous;
      errorMessage = "Unable to respond to invite.";
      notifyListeners();
    }
  }

  Future<void> acceptInvite(String id) => updateInviteStatus(id, InviteStatus.accept);

  Future<void> rejectInvite(String id) => updateInviteStatus(id, InviteStatus.reject);
}