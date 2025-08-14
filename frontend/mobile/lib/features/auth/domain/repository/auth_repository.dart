import 'package:smartagrichange_mobile/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<void> register(User user);
  Future<bool> login(String phone, String password);
  Future<bool> verifyOtp(String phone, String otp);
}