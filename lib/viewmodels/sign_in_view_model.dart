import 'package:flutter/foundation.dart';
import 'package:roamio_frontend/models/services/auth_service.dart';
import 'package:roamio_frontend/models/services/trip_account_service.dart';

class AuthHeaders {
  static Future<Map<String, String>> build({bool isJson = true}) async {
    final token = await AuthService.instance.getToken();

    return {
      if (isJson) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}

class SignInViewModel extends ChangeNotifier {
  SignInViewModel({TripAccountService? tripAccountService})
      : _tripAccountService = tripAccountService ?? TripAccountService();

  final TripAccountService _tripAccountService;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    _clearError();

    if (username.trim().isEmpty || password.isEmpty) {
      _errorMessage = 'Incorrect username or password.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _tripAccountService.login(username.trim(), password);

      await AuthService.instance.saveSession(
        token: result.token,
        userId: result.account.userId,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      debugPrint('SIGN IN ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      _isLoading = false;
      _errorMessage = 'Incorrect username or password.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}