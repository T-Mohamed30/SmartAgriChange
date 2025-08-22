import '../repository/auth_repository.dart';

class VerifyOtp {
  final AuthRepository repository;
  VerifyOtp(this.repository);

  Future<Map<String, dynamic>?> call(String phone, String otp) => repository.verifyOtp(phone, otp);
}