import 'package:roamio_frontend/models/services/auth_service.dart';

class AuthHeaders {
  AuthHeaders._();

  static Future<Map<String, String>> build({
    bool isJson = true,
  }) async {
    final headers = <String, String>{};

    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }

    final token = await AuthService.instance.getToken();

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}