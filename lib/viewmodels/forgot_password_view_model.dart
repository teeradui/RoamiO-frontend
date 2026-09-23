import 'package:flutter/foundation.dart';

enum ForgotPasswordStep {
  enterEmail,
  enterOtp,
  resetPassword,
  completed,
}

class ForgotPasswordViewModel extends ChangeNotifier {
  ForgotPasswordStep _currentStep = ForgotPasswordStep.enterEmail;

  bool _isLoading = false;
  String? _errorMessage;

  String? _registeredEmail;
  String? _mockOtp;

  ForgotPasswordStep get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Mock registered email
  final List<String> _registeredEmails = [
    'teerada@example.com',
    'test@example.com',
  ];

  // SRS-178, SRS-179
  Future<bool> requestPasswordReset(String email) async {
    _clearError();

    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      // SRS-186
      if (!_registeredEmails.contains(normalizedEmail)) {
        _errorMessage =
            'No account was found with this email.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _registeredEmail = normalizedEmail;

      // Mock OTP
      _mockOtp = '123456';

      debugPrint('========== PASSWORD RESET ==========');
      debugPrint('Email: $_registeredEmail');
      debugPrint('Mock OTP: $_mockOtp');
      debugPrint('====================================');

      _currentStep = ForgotPasswordStep.enterOtp;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // SRS-190
      _isLoading = false;
      _errorMessage =
          'Unable to reset your password. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // SRS-180, SRS-181
  Future<bool> verifyOtp(String otp) async {
    _clearError();

    if (otp.trim().isEmpty) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 700));

      // Mock OTP expiration check
      final isExpired = false;

      if (isExpired) {
        // SRS-188
        _errorMessage =
            'Your OTP has expired. Please request a new one.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // SRS-187
      if (otp.trim() != _mockOtp) {
        _errorMessage =
            'Invalid OTP. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentStep = ForgotPasswordStep.resetPassword;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // SRS-190
      _isLoading = false;
      _errorMessage =
          'Unable to reset your password. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // SRS-182
  Future<bool> resendOtp() async {
    _clearError();

    if (_registeredEmail == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      // Generate a new mock OTP
      _mockOtp = '654321';

      debugPrint('========== RESEND OTP ==========');
      debugPrint('Email: $_registeredEmail');
      debugPrint('New Mock OTP: $_mockOtp');
      debugPrint('================================');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // SRS-190
      _isLoading = false;
      _errorMessage =
          'Unable to reset your password. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // SRS-183, SRS-184, SRS-185
  Future<bool> resetPassword({
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    _clearError();

    if (newPassword != passwordConfirmation) {
      // SRS-189
      _errorMessage = 'Passwords do not match.';
      notifyListeners();
      return false;
    }

    if (newPassword.isEmpty || passwordConfirmation.isEmpty) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      // Mock password update
      debugPrint('========== PASSWORD UPDATED ==========');
      debugPrint('Email: $_registeredEmail');
      debugPrint('======================================');

      _currentStep = ForgotPasswordStep.completed;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // SRS-190
      _isLoading = false;
      _errorMessage =
          'Unable to reset your password. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void backToEmail() {
    _clearError();
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

  String? get registeredEmail => _registeredEmail;
}