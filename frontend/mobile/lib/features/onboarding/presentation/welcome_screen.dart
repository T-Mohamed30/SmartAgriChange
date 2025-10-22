import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartagrichange_mobile/features/onboarding/presentation/stepper_screen.dart';
import 'package:smartagrichange_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smartagrichange_mobile/features/auth/domain/entities/user.dart';
import 'package:smartagrichange_mobile/features/user_dashboard/home.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();

    // Check for existing authentication
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingLogin();
    });
  }

  Future<void> _checkExistingLogin() async {
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
          // Token is invalid, clear it and reset user state
          await prefs.clear();
          ref.read(userProvider.notifier).state = null;
        }
      } else {
        // No token found, ensure user state is null
        ref.read(userProvider.notifier).state = null;
      }
    } catch (e) {
      // Handle any errors gracefully, reset state
      print('Error checking existing login: $e');
      ref.read(userProvider.notifier).state = null;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Image.asset(
                'assets/images/logo.png', 
                height: MediaQuery.of(context).size.height * 0.15,
                semanticLabel: 'Logo SmartAgriChange',
              ),
            ),
            const SizedBox(height: 20),
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'SmartAgriChange',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Rejoignez la nouvelle génération d\'agriculteurs connectés.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const Spacer(),
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StepperScreen()),
                      );
                    },
                    child: const Text('Commencer', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
