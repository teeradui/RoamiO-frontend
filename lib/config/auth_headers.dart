/// Central place to build auth headers for API requests.
///
/// TODO: Replace the body with real token retrieval once auth is wired up
/// (e.g. read from secure storage / an AuthService). Every repository in the
/// app should call [AuthHeaders.build] instead of hardcoding headers, so this
/// is the only file that needs to change later.
class AuthHeaders {
  AuthHeaders._();

  static Future<Map<String, String>> build({bool isJson = true}) async {
    final headers = <String, String>{};
    if (isJson) headers['Content-Type'] = 'application/json';

    // final token = await SecureStorage.readToken();
    // if (token != null) headers['Authorization'] = 'Bearer $token';

    return headers;
  }
}