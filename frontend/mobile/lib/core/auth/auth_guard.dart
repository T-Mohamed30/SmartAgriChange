import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartagrichange_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smartagrichange_mobile/features/auth/domain/entities/user.dart';

class AuthGuard extends ConsumerWidget {
  final Widget child;
  final String? redirectTo;

  const AuthGuard({
    super.key,
    required this.child,
    this.redirectTo = '/auth/login',
  });

  Future<bool> _isAuthenticated(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) return false;

    try {
      final currentUserData = await ref.read(getCurrentUserProvider)();
      if (currentUserData == null) return false;

      // Update user provider with current user data
      ref.read(userProvider.notifier).state = User(
        nom: currentUserData['nom'] ?? '',
        prenom: currentUserData['prenom'] ?? '',
        phone: currentUserData['telephone'] ?? '',
        callingCode: '+226',
        password: '',
      );
      return true;
    } catch (_) {
      // Clear invalid token
      await prefs.clear();
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: _isAuthenticated(ref),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007F3D)),
              ),
            ),
          );
        }

        if (snapshot.data == true) {
          return child;
        } else {
          // Redirect to login after build is complete
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ModalRoute.of(context)?.settings.name != '/auth/login') {
              Navigator.of(context).pushReplacementNamed(redirectTo!);
            }
          });
          return const SizedBox.shrink();
        }
      },
    );
  }
}
