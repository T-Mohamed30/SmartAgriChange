import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartagrichange_mobile/features/auth/domain/entities/user.dart';
import 'providers/auth_provider.dart';

class OtpPage extends ConsumerStatefulWidget {
  final String phone;
  final int? userId;
  const OtpPage({super.key, required this.phone, this.userId});

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();

  // Factory constructor to create from route arguments
  factory OtpPage.fromArgs(Map<String, dynamic> args) {
    return OtpPage(
      phone: args['phone'] as String,
      userId: args['user_id'] as int?,
    );
  }
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Récupérer les infos utilisateur depuis le provider
      final user = ref.read(userProvider);
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Informations utilisateur manquantes. Veuillez recommencer l\'inscription.',
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Use the user ID passed from registration, or try to get from SharedPreferences as fallback
      int? userIdToUse = widget.userId;
      if (userIdToUse == null) {
        final prefs = await SharedPreferences.getInstance();
        userIdToUse = prefs.getInt('user_id');
      }

      if (userIdToUse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID utilisateur manquant. Veuillez recommencer l\'inscription.'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final result = await ref
          .read(verifyOtpProvider)
          .call(
            widget.phone,
            otpController.text,
            user.nom,
            user.prenom,
            user.password,
            userId: userIdToUse,
          );

      if (!mounted) return;

      if (result != null) {
        // Mettre à jour l'utilisateur connecté
        final updatedUser = User(
          nom: result['nom'] ?? '',
          prenom: result['prenom'] ?? '',
          phone: widget.phone,
          callingCode: '', // Not available in OTP response
          password: '', // Le mot de passe n'est pas nécessaire ici
        );
        ref.read(userProvider.notifier).state = updatedUser;

        // Nettoyer le contrôleur avant la navigation
        otpController.clear();
        // Naviguer vers la page de connexion après inscription réussie
        Navigator.of(context).pushNamedAndRemoveUntil('/auth/login', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP incorrect ou expiré')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Vérification OTP',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Text('Un code a été envoyé au ${widget.phone}'),
              const SizedBox(height: 24),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Code OTP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, letterSpacing: 4),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Vérifier',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
