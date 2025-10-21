class User {
  final String nom;
  final String prenom;
  final String phone;
  final String callingCode;
  final String password;
  User({
    required this.nom,
    required this.prenom,
    required this.phone,
    required this.callingCode,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'phone': phone,
      'calling_code': callingCode,
      // Ne pas inclure le mot de passe dans les logs pour des raisons de sécurité
    };
  }
}
