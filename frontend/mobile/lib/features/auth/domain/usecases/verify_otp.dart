import '../repository/auth_repository.dart';

class VerifyOtp {
  final AuthRepository repository;
  VerifyOtp(this.repository);

  Future<bool> call(String phone, String otp) => repository.verifyOtp(phone, otp);
}