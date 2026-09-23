import 'package:flutter/foundation.dart';

class SettingsViewModel extends ChangeNotifier {
  String _name = 'Teerada Bun-in';
  String _profileImagePath = 'assets/images/default_profile.png';

  String get name => _name;
  String get profileImagePath => _profileImagePath;

  void changeName(String name) {
    _name = name;
    notifyListeners();
  }

  void changeProfileImage(String path) {
    _profileImagePath = path;
    notifyListeners();
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      return false;
    }

    if (newPassword != confirmPassword) {
      return false;
    }

    // TODO: connect to backend later
    return true;
  }

  Future<bool> deleteAccount() async {
    // TODO: connect to backend later
    return true;
  }
}