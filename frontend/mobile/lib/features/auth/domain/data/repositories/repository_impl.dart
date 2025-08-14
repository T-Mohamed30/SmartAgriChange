import '../../entities/user.dart';
import '../../repository/auth_repository.dart';
import '../datasources/local_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalAuthDatasource datasource;
  AuthRepositoryImpl(this.datasource);

  @override
  Future<void> register(User user) async {
    await datasource.saveUser(user.phone, user.password);
  }

  @override
  Future<bool> login(String phone, String password) async {
    return await datasource.checkUser(phone, password);
  }

  // Stockage temporaire des OTP générés
  static final Map<String, String> _generatedOtps = {};

  @override
  Future<bool> verifyOtp(String phone, String otp) async {
    final storedOtp = _generatedOtps[phone];
    if (storedOtp == null) return false;
    
    final isValid = storedOtp == otp;
    if (isValid) {
      // Supprime l'OTP après utilisation
      _generatedOtps.remove(phone);
    }
    return isValid;
  }

  // Génère un OTP de 4 chiffres
  String generateOtp(String phone) {
    final otp = (1000 + (9999 - 1000) * (DateTime.now().millisecondsSinceEpoch % 9000) / 9000).round().toString();
    _generatedOtps[phone] = otp;
    
    // Simulation d'envoi SMS
    print('📱 OTP pour $phone: $otp');
    return otp;
  }
}