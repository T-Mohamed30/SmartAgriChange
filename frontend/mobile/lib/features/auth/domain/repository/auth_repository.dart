import 'package:smartagrichange_mobile/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<void> register(User user);
  Future<Map<String, dynamic>?> login(String phone, String password);
  Future<Map<String, dynamic>?> verifyOtp(
    String phone,
    String otp,
    String nom,
    String prenom,
    String motDePasse,
  );
}
