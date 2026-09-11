class ApiConfig {
  static const String baseUrl = 'http://10.121.100.80:3000/api';
  static const String trips = '$baseUrl/trips';
  static String tripMembers(String tripId) => '$trips/$tripId/members';
  static String tripInvites(String tripId) => '$trips/$tripId/invites';
  static String tripLocation(String tripId) => '$trips/$tripId/location';
  static String tripActivities(String tripId) => '$trips/$tripId/activities';
  static String userNotifications(String userId) => '$baseUrl/users/$userId/notifications';
}