import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartagrichange_mobile/features/auth/domain/entities/user.dart';
import 'package:smartagrichange_mobile/features/auth/presentation/providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool passwordVisible = false;

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final phone = phoneController.text.trim();
    final password = passwordController.text;

    // Vérification simple des champs
    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      // Appel à l'API de connexion
      final userData = await ref.read(loginUserProvider)(phone, password);
      
      if (userData != null && mounted) {
        // Mettre à jour les informations utilisateur
        final user = User(
          nom: userData['nom'] ?? '',
          prenom: userData['prenom'] ?? '',
          phone: phone,
          password: '', // Le mot de passe n'est pas stocké
        );
        print('📝 Mise à jour de l\'utilisateur: ${user.toJson()}');
        ref.read(userProvider.notifier).state = user;
        
        // Si la connexion est réussie, naviguer directement vers la page d'accueil
        if (mounted) {
          Navigator.of(context).pop();
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de connexion: ${e.toString()}')),
        );
      }
    }
  }

  void goToHome() {
    Navigator.pushReplacementNamed(context, '/home');
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
                    child: Image.asset('assets/images/feuille_1.png', width: 150),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Image.asset('assets/images/feuille_2.png', width: 150),
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
                      'Connexion',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Retrouvez vos analyses et vos conseils en un clic.',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      'Téléphone',
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
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
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF007F3D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _login,
                        child: const Text("Se connecter", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: const [
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
                            //connexion Google
                          },
                          icon: Image.asset('assets/images/google.png', height: 30),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          onPressed: () {
                            // connexion Facebook
                          },
                          icon: Image.asset('assets/images/facebook.png', height: 30),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Vous êtes nouveau ?"),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/auth/register');
                          },
                          child: const Text(
                            'Rejoignez-nous.',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF007F3D)),
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
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !passwordVisible,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: placeholder,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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