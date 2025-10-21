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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    // Initialize authentication state
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null || token.isEmpty) {
        // No token found, redirect to login
        if (ModalRoute.of(context)?.isCurrent == true && ModalRoute.of(context)?.settings.name != '/auth/login') {
          ref.read(userProvider.notifier).state = null;
          Navigator.of(context).pushReplacementNamed(redirectTo!);
        }
      } else if (user == null) {
        // Token exists but user state is null, try to restore user data
        try {
          final currentUserData = await ref.read(getCurrentUserProvider)();
          if (currentUserData != null) {
            final restoredUser = User(
              nom: currentUserData['nom'] ?? '',
              prenom: currentUserData['prenom'] ?? '',
              phone: currentUserData['telephone'] ?? '',
              callingCode: '+226', // Default, can be updated if needed
              password: '',
            );
            ref.read(userProvider.notifier).state = restoredUser;
          } else {
            // No user data available, redirect to login
            if (ModalRoute.of(context)?.isCurrent == true && ModalRoute.of(context)?.settings.name != '/auth/login') {
              Navigator.of(context).pushReplacementNamed(redirectTo!);
            }
          }
        } catch (e) {
          // Failed to get user data, redirect to login
          if (ModalRoute.of(context)?.isCurrent == true && ModalRoute.of(context)?.settings.name != '/auth/login') {
            Navigator.of(context).pushReplacementNamed(redirectTo!);
          }
        }
      }
    });

    return user != null ? child : const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
