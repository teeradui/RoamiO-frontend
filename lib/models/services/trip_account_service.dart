import '../repository/trip_account_repository.dart';
import '../trip_account_model.dart';

class TripAccountService {
  final TripAccountRepository _repo;

  TripAccountService({TripAccountRepository? repository})
      : _repo = repository ?? TripAccountRepository();

  Future<TripAccount> createAccount({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) {
    return _repo.createAccount(
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      password: password,
    );
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

  Future<TripAccount> deleteAccount(String userId) {
    return _repo.deleteAccount(userId);
  }
}