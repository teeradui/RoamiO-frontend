import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:roamio_frontend/models/services/trip_account_service.dart';

enum ForgotPasswordStep {
  enterEmail,
  enterOtp,
  resetPassword,
  completed,
}

class ForgotPasswordViewModel extends ChangeNotifier {
  final TripAccountService _service;

  ForgotPasswordViewModel({TripAccountService? service})
      : _service = service ?? TripAccountService();

  ForgotPasswordStep _currentStep = ForgotPasswordStep.enterEmail;

  bool _isLoading = false;
  String? _errorMessage;

  String? _registeredEmail;
  String? _resetToken;

  ForgotPasswordStep get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get registeredEmail => _registeredEmail;

  // SRS-178, SRS-179
  Future<bool> requestPasswordReset(String email) async {
    _clearError();

    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      _errorMessage = 'Please enter your email address.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _service.forgotPassword(normalizedEmail);

      _registeredEmail = normalizedEmail;
      _currentStep = ForgotPasswordStep.enterOtp;

      return true;
    } catch (e) {
  // SRS-187, SRS-188, SRS-190
  final error = e.toString().replaceFirst('Exception: ', '');

  if (error.toLowerCase().contains('expired')) {
    _errorMessage =
        'Your OTP has expired. Please request a new one.';
  } else if (error.toLowerCase().contains('attempt')) {
    _errorMessage =
        'Maximum OTP attempts exceeded. Please request a new OTP.';
  } else {
    _errorMessage = 'Invalid OTP. Please try again.';
  }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // SRS-180, SRS-181
  Future<bool> verifyOtp(String otp) async {
    _clearError();

    if (_registeredEmail == null) {
      _errorMessage = 'Please request a password reset first.';
      notifyListeners();
      return false;
    }

    if (otp.trim().isEmpty) {
      _errorMessage = 'Please enter the OTP.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try { 
      _resetToken = await _service.verifyResetOtp(
        _registeredEmail!,
        otp.trim(),
      );

      _currentStep = ForgotPasswordStep.resetPassword;

      return true;
    } catch (e) {
      // SRS-187, SRS-188, SRS-190
      final error = e.toString().replaceFirst('Exception: ', '');

      if (error.toLowerCase().contains('expired')) {
        _errorMessage =
            'Your OTP has expired. Please request a new one.';
      } else if (error.toLowerCase().contains('attempt')) {
        _errorMessage =
            'Maximum OTP attempts exceeded. Please request a new OTP.';
      } else {
        _errorMessage = 'Invalid OTP. Please try again.';
      }

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // SRS-182
  Future<bool> resendOtp() async {
    _clearError();

    if (_registeredEmail == null) {
      _errorMessage = 'Please enter your email address first.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _service.forgotPassword(_registeredEmail!);

      _resetToken = null;

      return true;
    } catch (e) {
      // SRS-190
      _errorMessage =
          'Unable to send a new OTP. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // SRS-183, SRS-184, SRS-185
  Future<bool> resetPassword({
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    _clearError();

    if (newPassword.isEmpty || passwordConfirmation.isEmpty) {
      _errorMessage = 'Please complete both password fields.';
      notifyListeners();
      return false;
    }

    if (newPassword.length < 8) {
      _errorMessage = 'Password must be at least 8 characters.';
      notifyListeners();
      return false;
    }

    if (newPassword != passwordConfirmation) {
      // SRS-189
      _errorMessage = 'Passwords do not match.';
      notifyListeners();
      return false;
    }

    if (_resetToken == null) {
      _errorMessage = 'Please verify your OTP first.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      
      await _service.resetPassword(
        _resetToken!,
        newPassword,
      );

      _resetToken = null;
      _currentStep = ForgotPasswordStep.completed;

      return true;
    } catch (e) {
      // SRS-190
      if (e is SocketException) {
    _errorMessage = 'Request failed. Please check your connection.';
  } else {
    final error = e.toString().replaceFirst('Exception: ', '');

    _errorMessage = error.contains('expired') ||
            error.contains('token')
        ? 'Your reset session has expired. Please request a new OTP.'
        : 'Unable to reset your password. Please try again.';
  }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void backToEmail() {
    _clearError();
    _registeredEmail = null;
    _resetToken = null;
    _currentStep = ForgotPasswordStep.enterEmail;
    notifyListeners();
  }

  void backToOtp() {
    _clearError();
    _currentStep = ForgotPasswordStep.enterOtp;
    notifyListeners();
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}