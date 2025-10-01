import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000/api', 
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // Ajouter un intercepteur pour le token d'authentification
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      
      return handler.next(options);
    },
    onError: (error, handler) async {
      // Gérer les erreurs d'authentification
      if (error.response?.statusCode == 401) {
        // Rediriger vers l'écran de connexion ou rafraîchir le token
      }
      return handler.next(error);
    },
  ));

  return dio;
});
