import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl;

  AuthService({
    required this.baseUrl,
  });

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
    String? profilePicturePath,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'profilePicture': profilePicturePath,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    if (response.statusCode == 409) {
      final data = jsonDecode(response.body);

      throw AuthException(
        data['message'] ?? 'Registration conflict.',
      );
    }

    throw AuthException(
      'Unable to create your account. Please try again.',
    );
  }
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}