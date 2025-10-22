import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartagrichange_mobile/features/auth/domain/entities/user.dart';
import 'package:smartagrichange_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smartagrichange_mobile/features/user_dashboard/home.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool passwordVisible = false;
  String selectedCallingCode = '+226'; // Default to Burkina Faso
  String completePhoneNumber =
      ''; // Store the complete international phone number

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    // Extract phone number without calling code
    final phoneNumber = phoneController.text.trim();
    final password = passwordController.text;

    // Vérification simple des champs
    if (phoneNumber.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    // Show loading dialog with better UX
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007F3D)),
          ),
        );
      },
    );

    try {
      // Appel à l'API de connexion
      final userData = await ref.read(loginUserProvider)(
        phoneNumber,
        password,
        selectedCallingCode,
      );

      if (userData != null && mounted) {
        // Mettre à jour les informations utilisateur avec les données du login
        final user = User(
          nom: userData['nom'] ?? '',
          prenom: userData['prenom'] ?? '',
          phone: phoneNumber,
          callingCode: selectedCallingCode,
          password: '', // Le mot de passe n'est pas stocké
        );

        ref.read(userProvider.notifier).state = user;

        // Clear any cached user data to ensure fresh login
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_id');

        // Si la connexion est réussie, naviguer directement vers la page d'accueil
        // Note: Token is already saved by the repository implementation
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog

          // Use pushNamedAndRemoveUntil to clear navigation stack
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        print('Erreur de connexion capturée: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de connexion: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingLogin();
    });
  }

  void _checkExistingLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token != null && token.isNotEmpty) {
        // Token exists, try to validate it with /auth/me
        try {
          final currentUserData = await ref.read(getCurrentUserProvider)();
          if (currentUserData != null && mounted) {
            // Token is valid, navigate to home
            final user = User(
              nom: currentUserData['nom'] ?? '',
              prenom: currentUserData['prenom'] ?? '',
              phone: currentUserData['telephone'] ?? '',
              callingCode: '+226', // Default, can be updated if needed
              password: '',
            );
            ref.read(userProvider.notifier).state = user;
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          }
        } catch (e) {
          // Token is invalid, clear it
          await prefs.remove('jwt_token');
          await prefs.remove('user_id');
          await prefs.clear();
        }
      }
    } catch (e) {
      // Handle any errors gracefully
      print('Error checking existing login: $e');
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
                      'Connexion',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Retrouvez vos analyses et vos conseils en un clic.',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 24),
                    _buildPhoneField(),
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
                          backgroundColor: const Color(0xFF007F3D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _login,
                        child: const Text(
                          "Se connecter",
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
                            //connexion Google
                          },
                          icon: Image.asset(
                            'assets/images/google.png',
                            height: 30,
                          ),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          onPressed: () {
                            // connexion Facebook
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
                        const Text("Vous êtes nouveau ?"),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/auth/register');
                          },
                          child: const Text(
                            'Rejoignez-nous.',
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

  Widget _buildPhoneField() {
    return IntlPhoneField(
      controller: phoneController,
      decoration: InputDecoration(
        hintText: 'Numéro de téléphone',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
      ),
      initialCountryCode: 'BF', // Burkina Faso
      onChanged: (phone) {
        setState(() {
          completePhoneNumber =
              phone.completeNumber; // Store the complete international number
        });
      },
      onCountryChanged: (country) {
        setState(() {
          selectedCallingCode = '+${country.dialCode}';
        });
      },
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
