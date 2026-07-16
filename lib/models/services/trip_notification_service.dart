import '../repository/trip_notification_repository.dart';
import '../trip_notification_model.dart';

class NotificationService {
  final NotificationRepository _repo;

  NotificationService({NotificationRepository? repository})
      : _repo = repository ?? NotificationRepository();

  Future<List<TripNotification>> getNotifications(String userId, {bool forceRefresh = false}) {
    return _repo.findByUser(userId, forceRefresh: forceRefresh);
  }

  Future<void> deleteNotification(String userId, String notificationId) {
    return _repo.delete(userId, notificationId);
  }
}