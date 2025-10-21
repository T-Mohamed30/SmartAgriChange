import '../repository/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;
  LoginUser(this.repository);

  Future<Map<String, dynamic>?> call(String phone, String password, String callingCode) => repository.login(phone, password, callingCode);
}
