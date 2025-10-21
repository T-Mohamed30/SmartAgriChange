import '../entities/user.dart';
import '../repository/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;
  RegisterUser(this.repository);

  Future<Map<String, dynamic>?> call(User user) => repository.register(user);
}
