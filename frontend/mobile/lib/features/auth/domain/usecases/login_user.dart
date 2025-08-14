import '../repository/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;
  LoginUser(this.repository);

  Future<bool> call(String phone, String password) => repository.login(phone, password);
}