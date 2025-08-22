import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../entities/user.dart';
import '../../repository/auth_repository.dart';

class RemoteAuthRepository implements AuthRepository {
  final String baseUrl;

  RemoteAuthRepository({required this.baseUrl});
  
  @override
  Future<void> register(User user) async {
    try {
      final url = Uri.parse('$baseUrl/auth/register');
      print('Envoi de la requête à: $url');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'nom': user.nom,
          'prenom': user.prenom,
          'telephone': user.phone,
          'mot_de_passe': user.password,
        }),
      );

      print('Réponse du serveur: ${response.statusCode}');
      print('Corps de la réponse: ${response.body}');

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Erreur lors de l\'inscription');
      }

    } catch (e) {
      print('Erreur lors de la requête: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> login(String phone, String password) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login');
      print('Tentative de connexion à: $url');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'telephone': phone,
          'mot_de_passe': password,
        }),
      );

      print('Réponse du serveur: ${response.statusCode}');
      print('Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['user'] != null) {
          return {
            'nom': responseData['user']['nom'] ?? '',
            'prenom': responseData['user']['prenom'] ?? '',
            'telephone': phone,
          };
        }
        return null;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Échec de la connexion');
      }
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> verifyOtp(String phone, String otp) async {
    try {
      final url = Uri.parse('$baseUrl/auth/verify-otp');
      print('🔐 Vérification OTP pour $phone');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'telephone': phone,
          'otp': otp,
        }),
      );

      print('📡 Réponse du serveur: ${response.statusCode}');
      print('📦 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Si le code est 200 ou 201, la vérification est réussie
        print('✅ Code de statut valide: ${response.statusCode}');
        final responseData = jsonDecode(response.body);
        print('📊 Réponse complète du serveur: $responseData');
        
        // Vérifier si la réponse contient un token
        final token = responseData['token'];
        if (token != null) {
          print('🔑 Token JWT reçu');
        } else {
          print('⚠️ Aucun token JWT dans la réponse');
        }
        
        // Vérifier la structure des données utilisateur
        if (responseData['user'] != null) {
          print('👤 Données utilisateur trouvées dans la réponse');
          print('   - Type de user: ${responseData['user'].runtimeType}');
          print('   - Contenu de user: ${responseData['user']}');
          
          final userData = {
            'nom': responseData['user']['nom'] ?? 'Non spécifié',
            'prenom': responseData['user']['prenom'] ?? 'Non spécifié',
            'telephone': phone,
          };
          
          print('👤 Utilisateur extrait: $userData');
          return userData;
        } else {
          print('⚠️ Aucune donnée utilisateur trouvée dans la réponse');
          print('   - Clés disponibles: ${responseData.keys}');
        }
        return null;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Échec de la vérification OTP');
      }
    } catch (e) {
      print('Erreur lors de la vérification OTP: $e');
      rethrow;
    }
  }
  
  

}
