import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  final Dio dio;

  DioClient()
      : dio = Dio(BaseOptions(
          baseUrl: 'https://smartagrichangeapi.kgslab.com/api',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        )) {
    // Ajouter un intercepteur pour le token d'authentification
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('jwt_token');

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint('Sending request to ${options.uri} with token: ${token.substring(0, 20)}...');
        } else {
          debugPrint('No token found for request to ${options.uri}');
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
  }
}
