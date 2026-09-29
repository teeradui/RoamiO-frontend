import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:roamio_frontend/models/services/trip_account_service.dart';

class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel({TripAccountService? tripAccountService})
      : _tripAccountService = tripAccountService ?? TripAccountService();

  final TripAccountService _tripAccountService;
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
      try {
        final isTaken = await _tripAccountService.checkUsernameTaken(
          _formatUsername(value),
        );

        _usernameError = isTaken ? 'This username is already taken.' : null;
      } catch (error, stackTrace) {
        debugPrint('CHECK USERNAME ERROR: $error');
        debugPrintStack(stackTrace: stackTrace);

        // Fail open: don't block registration on a network hiccup during
        // a live-typing check. The real uniqueness constraint is still
        // enforced server-side when createAccount is submitted.
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
      try {
        final isTaken = await _tripAccountService.checkEmailTaken(value);

        _emailError = isTaken ? 'This email is already registered.' : null;
      } catch (error, stackTrace) {
        debugPrint('CHECK EMAIL ERROR: $error');
        debugPrintStack(stackTrace: stackTrace);

        // Fail open — same reasoning as checkUsername.
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

      await _tripAccountService.createAccount(
        firstName: name.trim(),
        username: formattedUsername,
        email: email,
        password: password,
        profilePicture: profilePicturePath != null ? File(profilePicturePath) : null,
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (error, stackTrace) {
      debugPrint('REGISTER ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

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
