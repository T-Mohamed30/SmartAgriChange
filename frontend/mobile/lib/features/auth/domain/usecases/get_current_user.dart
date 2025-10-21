import '../repository/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository repository;
  GetCurrentUser(this.repository);

  Future<Map<String, dynamic>?> call() => repository.getCurrentUser();
}
