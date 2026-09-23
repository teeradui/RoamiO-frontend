import 'dart:async';

import 'package:flutter/foundation.dart';

class RegisterViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  String? _usernameError;
  String? _emailError;
  String? _confirmPasswordError;

  Timer? _usernameDebounce;
  Timer? _emailDebounce;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? get usernameError => _usernameError;
  String? get emailError => _emailError;
  String? get confirmPasswordError => _confirmPasswordError;

  Future<void> checkUsername(String username) async {
    _usernameDebounce?.cancel();

    final value = username.trim();

    if (value.isEmpty) {
      _usernameError = 'Please enter your username.';
      notifyListeners();
      return;
    }

    _usernameError = null;
    notifyListeners();

    _usernameDebounce = Timer(const Duration(milliseconds: 500), () async {
      // TODO: Replace with real API call later.
      //
      // final isTaken =
      //     await authService.checkUsername('@$value');

      // Temporary: no DB yet, so assume username is available.
      final isTaken = false;

      if (isTaken) {
        _usernameError = 'This username is already taken.';
      } else {
        _usernameError = null;
      }

      notifyListeners();
    });
  }

  void checkPasswordMatch({
    required String password,
    required String confirmPassword,
  }) {
    if (confirmPassword.isEmpty) {
      _confirmPasswordError = 'Please confirm your password.';
    } else if (password != confirmPassword) {
      _confirmPasswordError = 'Passwords do not match.';
    } else {
      _confirmPasswordError = null;
    }

    notifyListeners();
  }

  Future<void> checkEmail(String email) async {
    _emailDebounce?.cancel();

    final value = email.trim();

    if (value.isEmpty) {
      _emailError = 'Please enter your email.';
      notifyListeners();
      return;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(value)) {
      _emailError = 'Please enter a valid email address.';
      notifyListeners();
      return;
    }

    _emailError = null;
    notifyListeners();

    _emailDebounce = Timer(const Duration(milliseconds: 500), () async {
      // TODO: Replace with real API call later.
      //
      // final isRegistered =
      //     await authService.checkEmail(value);

      // Temporary: no DB yet, so assume email is available.
      final isRegistered = false;

      if (isRegistered) {
        _emailError = 'This email is already registered.';
      } else {
        _emailError = null;
      }

      notifyListeners();
    });
  }

  Future<bool> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? profilePicturePath,
  }) async {
    _clearError();

    if (password != passwordConfirmation) {
      _errorMessage = 'Passwords do not match.';
      notifyListeners();
      return false;
    }

    if (_usernameError != null || _emailError != null) {
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final formattedUsername = _formatUsername(username);

      debugPrint('========== REGISTER ==========');
      debugPrint('Name: $name');
      debugPrint('Username: $formattedUsername');
      debugPrint('Email: $email');
      debugPrint('Profile picture: $profilePicturePath');
      debugPrint('==============================');

      // Mock registration until backend is connected.
      await Future.delayed(const Duration(seconds: 1));

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Unable to create your account. Please try again.';
      notifyListeners();
      return false;
    }
  }

  String _formatUsername(String username) {
    final trimmedUsername = username.trim();

    if (trimmedUsername.startsWith('@')) {
      return trimmedUsername;
    }

    return '@$trimmedUsername';
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _usernameDebounce?.cancel();
    _emailDebounce?.cancel();
    super.dispose();
  }
}
