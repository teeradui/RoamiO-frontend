import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';
  static const _userNameKey = 'auth_user_name';

  String? _cachedUserName;
  String? _cachedToken;
  String? _cachedUserId;

  Future<void> saveSession({required String token, required String userId, required String userName,}) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _userNameKey, value: userName);
    _cachedToken = token;
    _cachedUserId = userId;
    _cachedUserName = userName;
  }

  Future<String?> getToken() async {
    return _cachedToken ??= await _storage.read(key: _tokenKey);
  }

  Future<String?> getCurrentUserId() async {
    return _cachedUserId ??= await _storage.read(key: _userIdKey);
  }

  Future<String?> getCurrentUserName() async {
  return _cachedUserName ??=
      await _storage.read(key: _userNameKey);
  }

  Future<bool> isLoggedIn() async => (await getToken()) != null;

  Future<void> logout() async {
    await _storage.deleteAll();
    _cachedToken = null;
    _cachedUserId = null;
    _cachedUserName = null;
  }
}