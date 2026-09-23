import 'package:flutter/foundation.dart';

class SignInViewModel extends ChangeNotifier {
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
      // Mock authentication
      // Backend will be connected here later.
      await Future.delayed(
        const Duration(seconds: 1),
      );

      _isLoading = false;
      notifyListeners();

      // SRS-172
      // Temporary: assume the credentials are valid.
      return true;
    } catch (e) {
      _isLoading = false;

      // SRS-176
      _errorMessage =
          'Unable to sign in. Please try again.';

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