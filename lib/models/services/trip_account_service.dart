import 'dart:async';

import '../repository/trip_account_repository.dart';
import '../trip_account_model.dart';
import 'dart:io';

class TripAccountService {
  final TripAccountRepository _repo;

  TripAccountService({TripAccountRepository? repository})
      : _repo = repository ?? TripAccountRepository();

  Future<TripAccount> createAccount({
    required String firstName,
    String? lastName,
    required String username,
    required String email,
    required String password,
    File? profilePicture,
  }) {
    return _repo.createAccount(
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      password: password,
      profilePicture: profilePicture,
    );
  }

  Future<LoginResult> login(String username, String password) {
    return _repo.login(username, password);
  }

  Future<TripAccount> updateAccount(String userId, Map<String, dynamic> fields) {
    return _repo.updateAccount(userId, fields);
  }

  Future<TripAccount> getAccountById(String userId) {
    return _repo.getAccountById(userId);
  }

  Future<List<TripAccount>> getAllAccounts() {
    return _repo.getAllAccounts();
  }

  Future<List<AccountTrip>> getAccountTrips(String userId) {
    return _repo.getAccountTrips(userId);
  }

  Future<bool> checkUsernameTaken(String username) {
    return _repo.checkUsernameTaken(username);
  }

  Future<bool> checkEmailTaken(String email) {
    return _repo.checkEmailTaken(email);
  }

  Future<List<AccountAward>> getAwardsByUserId(String userId) {
    return _repo.getAwardsByUserId(userId);
  }
  
  Future<TripAccount> deleteAccount(String userId) {
    return _repo.deleteAccount(userId);
  }
}