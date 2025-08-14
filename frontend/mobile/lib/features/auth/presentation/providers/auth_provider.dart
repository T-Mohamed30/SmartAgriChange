import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/data/datasources/local_auth_datasource.dart';
import '../../domain/data/repositories/repository_impl.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/verify_otp.dart';

final localAuthDatasourceProvider = Provider((ref) => LocalAuthDatasource());
final authRepositoryProvider = Provider((ref) => AuthRepositoryImpl(ref.read(localAuthDatasourceProvider)));

final registerUserProvider = Provider((ref) => RegisterUser(ref.read(authRepositoryProvider)));
final loginUserProvider = Provider((ref) => LoginUser(ref.read(authRepositoryProvider)));
final verifyOtpProvider = Provider((ref) => VerifyOtp(ref.read(authRepositoryProvider)));