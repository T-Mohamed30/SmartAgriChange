import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartagrichange_mobile/features/auth/domain/repository/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/verify_otp.dart';
import '../../domain/data/repositories/repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // Pour émulateur Android : 'http://10.0.2.2:3000'
  // Pour émulateur iOS : 'http://localhost:3000'
  // Pour appareil physique : 'http://<votre-ip-locale>:3000'
  return RemoteAuthRepository(baseUrl: 'http://172.16.7.71:3000/api');
});

final registerUserProvider = Provider((ref) => RegisterUser(ref.read(authRepositoryProvider)));
final loginUserProvider = Provider((ref) => LoginUser(ref.read(authRepositoryProvider)));
final verifyOtpProvider = Provider((ref) => VerifyOtp(ref.read(authRepositoryProvider)));

// État de l'utilisateur connecté
final userProvider = StateProvider<User?>((ref) => null);
