import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';

  String? _cachedToken;
  String? _cachedUserId;

  Future<void> saveSession({required String token, required String userId}) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId);
    _cachedToken = token;
    _cachedUserId = userId;
  }

  Future<String?> getToken() async {
    return _cachedToken ??= await _storage.read(key: _tokenKey);
  }

  Future<String?> getCurrentUserId() async {
    return _cachedUserId ??= await _storage.read(key: _userIdKey);
  }

  Future<bool> isLoggedIn() async => (await getToken()) != null;

  Future<void> logout() async {
    await _storage.deleteAll();
    _cachedToken = null;
    _cachedUserId = null;
  }
}