import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../entities/user.dart';
import '../../repository/auth_repository.dart';

class RemoteAuthRepository implements AuthRepository {
  final String baseUrl;
  final Dio dio = Dio();

  RemoteAuthRepository({required this.baseUrl});

  @override
  Future<void> register(User user) async {
    final url = '$baseUrl/auth/register';
    final response = await dio.post(
      url,
      data: {
        'nom': user.nom,
        'prenom': user.prenom,
        'telephone': user.phone,
        'mot_de_passe': user.password,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      ),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = response.data;
      final token = responseData['token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
      }
    } else {
      throw Exception(
        response.data['message'] ?? 'Erreur lors de l\'inscription',
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> login(String phone, String password) async {
    final url = '$baseUrl/auth/login';
    final response = await dio.post(
      url,
      data: {'telephone': phone, 'mot_de_passe': password},
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      ),
    );
    if (response.statusCode == 200) {
      final responseData = response.data;
      final token = responseData['token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
      }
      if (responseData['user'] != null) {
        return {
          'nom': responseData['user']['nom'] ?? '',
          'prenom': responseData['user']['prenom'] ?? '',
          'telephone': phone,
        };
      }
      return null;
    } else {
      throw Exception(response.data['message'] ?? 'Échec de la connexion');
    }
  }

  @override
  Future<Map<String, dynamic>?> verifyOtp(
    String phone,
    String otp,
    String nom,
    String prenom,
    String motDePasse,
  ) async {
    final url = '$baseUrl/auth/verify-otp';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final response = await dio.post(
      url,
      data: {
        'telephone': phone,
        'otp': otp,
        'nom': nom,
        'prenom': prenom,
        'mot_de_passe': motDePasse,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = response.data;
      if (responseData['user'] != null) {
        return {
          'nom': responseData['user']['nom'] ?? 'Non spécifié',
          'prenom': responseData['user']['prenom'] ?? 'Non spécifié',
          'telephone': phone,
        };
      }
      return null;
    } else {
      throw Exception(
        response.data['message'] ?? 'Échec de la vérification OTP',
      );
    }
  }
}
