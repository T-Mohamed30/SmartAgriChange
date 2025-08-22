import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartagrichange_mobile/features/auth/presentation/providers/auth_provider.dart';

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
    final isInitialized = user != null;

    // Rediriger si l'utilisateur n'est pas connecté
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isInitialized && ModalRoute.of(context)?.isCurrent == true) {
        Navigator.of(context).pushReplacementNamed(redirectTo!);
      }
    });

    return isInitialized ? child : const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
