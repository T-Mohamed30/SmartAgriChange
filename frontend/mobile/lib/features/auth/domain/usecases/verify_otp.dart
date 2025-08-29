import '../repository/auth_repository.dart';

class VerifyOtp {
  final AuthRepository repository;
  VerifyOtp(this.repository);

  Future<Map<String, dynamic>?> call(
    String phone,
    String otp,
    String nom,
    String prenom,
    String motDePasse,
  ) => repository.verifyOtp(phone, otp, nom, prenom, motDePasse);
}
