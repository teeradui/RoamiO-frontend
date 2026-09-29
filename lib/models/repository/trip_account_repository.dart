import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../config/auth_headers.dart';
import '../trip_account_model.dart';

/// Raw data access for accounts.
/// Throws on any failure — callers (TripAccountService) decide how to handle it.
class TripAccountRepository {
  String get _base => ApiConfig.accounts;

  Future<TripAccount> createAccount({
    required String firstName,
    String? lastName,
    required String username,
    required String email,
    required String password,
    File? profilePicture,
  }) async {
    final uri = Uri.parse(_base);
    final request = http.MultipartRequest('POST', uri);

    request.fields['firstName'] = firstName;
    if (lastName != null && lastName.trim().isNotEmpty) {
      request.fields['lastName'] = lastName;
    }
    request.fields['username'] = username;
    request.fields['email'] = email;
    request.fields['password'] = password;

    if (profilePicture != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profilePicture', profilePicture.path),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        'Failed to create account (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    return TripAccount.fromJson(decoded['account'] as Map<String, dynamic>);
  }

  Future<LoginResult> login(String username, String password) async {
    final uri = Uri.parse('$_base/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['error']?.toString() ?? 'Login failed.');
    }

    final decoded = jsonDecode(response.body);
    return LoginResult.fromJson(decoded);
  }

  Future<TripAccount> updateAccount(String userId, Map<String, dynamic> fields) async {
    final uri = Uri.parse('$_base/$userId');
    final headers = await AuthHeaders.build();

    final response = await http.patch(
      uri,
      headers: headers,
      body: jsonEncode(fields),
    );

    if (response.statusCode == 403) {
      throw Exception('You can only update your own account.');
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update account (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    return TripAccount.fromJson(decoded['account'] as Map<String, dynamic>);
  }

  Future<TripAccount> getAccountById(String userId) async {
    final uri = Uri.parse('$_base/$userId');
    final headers = await AuthHeaders.build();

    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load account (${response.statusCode}): ${response.body}',
      );
    }

    return TripAccount.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<TripAccount>> getAllAccounts() async {
    final uri = Uri.parse('$_base/all');
    final headers = await AuthHeaders.build();

    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load accounts (${response.statusCode}): ${response.body}',
      );
    }

    // Note: controller returns a raw array (no wrapper key).
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => TripAccount.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TripAccount> deleteAccount(String userId) async {
    final uri = Uri.parse('$_base/$userId');
    final headers = await AuthHeaders.build();

    final response = await http.delete(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete account (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    return TripAccount.fromJson(decoded['account'] as Map<String, dynamic>);
  }

  Future<List<AccountTrip>> getAccountTrips(String userId) async {
    final uri = Uri.parse('$_base/$userId/trips');
    final headers = await AuthHeaders.build();

    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load accounts trips (${response.statusCode}): ${response.body}',
      );
    }
    
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => AccountTrip.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<bool> checkUsernameTaken(String username) async {
    final uri = Uri.parse('$_base/checkUsername').replace(
      queryParameters: {'username': username},
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to check username (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    return decoded['isTaken'] as bool;
  }

  Future<bool> checkEmailTaken(String email) async {
    final uri = Uri.parse('$_base/checkEmail').replace(
      queryParameters: {'email': email},
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to check email (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    return decoded['isTaken'] as bool;
  }

  Future<List<AccountAward>> getAwardsByUserId(String userId) async {
    final uri = Uri.parse('$_base/$userId/awards');
    final headers = await AuthHeaders.build();

    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load awards (${response.statusCode}): ${response.body}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => AccountAward.fromJson(e as Map<String, dynamic>)).toList();
  }
  }