import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../config/auth_headers.dart';
import '../tripNotificationModel.dart';

/// Raw data access for user notifications. Throws on any failure —
/// NotificationService decides how to handle it.
class NotificationRepository {
  final Map<String, List<TripNotification>> _cache = {}; // keyed by userId

  void _invalidate(String userId) => _cache.remove(userId);

  Future<List<TripNotification>> findByUser(String userId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _cache.containsKey(userId)) {
      return _cache[userId]!;
    }

    final uri = Uri.parse(ApiConfig.userNotifications(userId));
    final headers = await AuthHeaders.build();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to load notifications (${response.statusCode}): ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    final notifications = data.map((e) => TripNotification.fromJson(e)).toList();
    _cache[userId] = notifications;
    return notifications;
  }

  Future<void> delete(String userId, String notificationId) async {
    final uri = Uri.parse('${ApiConfig.userNotifications(userId)}/$notificationId');
    final headers = await AuthHeaders.build();
    final response = await http.delete(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete notification (${response.statusCode}): ${response.body}');
    }

    _invalidate(userId);
  }
}