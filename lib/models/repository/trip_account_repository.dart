import 'dart:convert';

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
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse(_base);

    // TODO: add soon — signup happens before a token exists, so no auth
    // headers are sent for this request.
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        'Failed to create account (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    return TripAccount.fromJson(decoded['account'] as Map<String, dynamic>);
  }

  Future<TripAccount> updateAccount(String userId, Map<String, dynamic> fields) async {
    final uri = Uri.parse('$_base/$userId');

    // TODO: add soon — should require AuthHeaders once JWT auth exists.
    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(fields),
    );

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

    // TODO: add soon — should require AuthHeaders once JWT auth exists.
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load account (${response.statusCode}): ${response.body}',
      );
    }

    // Note: controller returns the account object directly (no wrapper key).
    return TripAccount.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<TripAccount>> getAllAccounts() async {
    final uri = Uri.parse('$_base/all');

    // TODO: add soon — should require AuthHeaders once JWT auth exists.
    final response = await http.get(uri);

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

    // TODO: add soon — should require AuthHeaders once JWT auth exists.
    final response = await http.delete(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete account (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    return TripAccount.fromJson(decoded['account'] as Map<String, dynamic>);
  }
}