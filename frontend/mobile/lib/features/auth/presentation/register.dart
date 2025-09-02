import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/auth_provider.dart';
import '../domain/entities/user.dart';
import '../domain/data/repositories/repository_impl.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Validation du téléphone
  bool _isValidPhone(String phone) {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone);
  }

  // Validation du mot de passe
  bool _isValidPassword(String password) {
    return password.length >= 8 && 
           password.contains(RegExp(r'[A-Z]')) &&
           password.contains(RegExp(r'[0-9]'));
  }

  void _register() async {
    final nom = nomController.text.trim();
    final prenom = prenomController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (nom.isEmpty ||
        prenom.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    if (!_isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format de téléphone invalide')),
      );
      return;
    }

    if (!_isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le mot de passe doit contenir au moins 8 caractères, une majuscule et un chiffre')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final user = User(
        nom: nom,
        prenom: prenom,
        phone: phone,
        password: password,
      );

      await ref.read(registerUserProvider).call(user);
      
      if (mounted) {
        Navigator.of(context).pop(); // Fermer le dialogue de chargement
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscription réussie! OTP envoyé par SMS')),
        );
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/auth/otp', arguments: phone);
        }
      }
    } catch (e) {
      print('Erreur lors de l\'inscription: $e');
      
      if (mounted) {
        Navigator.of(context).pop(); // Fermer le dialogue de chargement en cas d'erreur
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Image.asset(
                      'assets/images/feuille_1.png',
                      width: 150,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Image.asset(
                      'assets/images/feuille_2.png',
                      width: 150,
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Image.asset('assets/images/logo.png', height: 80),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Inscription',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Augmentez vos rendements avec l’IA.',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      'Nom',
                      controller: nomController,
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Prénom',
                      controller: prenomController,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Téléphone',
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      icon: Icons.phone,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Mot de passe',
                      controller: passwordController,
                      isPassword: true,
                      passwordVisible: passwordVisible,
                      onEyeTap: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                      icon: Icons.lock,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Confirmer mot de passe',
                      controller: confirmPasswordController,
                      isPassword: true,
                      passwordVisible: confirmPasswordVisible,
                      onEyeTap: () {
                        setState(() {
                          confirmPasswordVisible = !confirmPasswordVisible;
                        });
                      },
                      icon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007F3D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _register,
                        child: const Text(
                          "S'inscrire",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Expanded(child: Divider(thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('OU'),
                        ),
                        Expanded(child: Divider(thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            // Inscription avec Google
                          },
                          icon: Image.asset(
                            'assets/images/google.png',
                            height: 30,
                          ),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          onPressed: () {
                            // Inscription avec Facebook
                          },
                          icon: Image.asset(
                            'assets/images/facebook.png',
                            height: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Vous avez déjà un compte ? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/auth/login');
                          },
                          child: const Text(
                            'Se connecter.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF007F3D),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String placeholder, {
    bool isPassword = false,
    TextInputType? keyboardType,
    TextEditingController? controller,
    bool passwordVisible = false,
    VoidCallback? onEyeTap,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !passwordVisible,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: placeholder,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: onEyeTap,
              )
            : null,
      ),
    );
  }
}
