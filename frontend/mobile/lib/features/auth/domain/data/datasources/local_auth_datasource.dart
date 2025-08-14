import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class LocalAuthDatasource {
  static const String _usersKey = 'registered_users';

  // Hash du mot de passe avec SHA256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> saveUser(String phone, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final hashedPassword = _hashPassword(password);
    
    // Récupère les utilisateurs existants
    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final users = Map<String, String>.from(jsonDecode(usersJson));
    
    // Ajoute le nouvel utilisateur
    users[phone] = hashedPassword;
    
    // Sauvegarde
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  Future<bool> checkUser(String phone, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final users = Map<String, String>.from(jsonDecode(usersJson));
    
    final storedHashedPassword = users[phone];
    if (storedHashedPassword == null) return false;
    
    final hashedPassword = _hashPassword(password);
    return storedHashedPassword == hashedPassword;
  }
}