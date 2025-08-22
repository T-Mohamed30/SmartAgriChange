import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartagrichange_mobile/core/auth/auth_guard.dart';
import 'package:smartagrichange_mobile/features/weather/presentation/providers/weather_provider.dart';
import 'package:smartagrichange_mobile/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/presentation/detection_capteurs.dart';
import 'package:smartagrichange_mobile/features/user_dashboard/home.dart';
import 'features/onboarding/presentation/welcome_screen.dart';
import 'features/onboarding/presentation/stepper_screen.dart';
import 'features/auth/presentation/register.dart';
import 'features/auth/presentation/login.dart';
import 'features/auth/presentation/otp_page.dart';
import 'features/soil_analysis/presentation/analysis_screen.dart';
import 'features/soil_analysis/presentation/crop_detail_screen.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        weatherRepositoryProvider.overrideWithValue(WeatherRepository()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF007F3D);
    final textColor = const Color(0xFF333333);
    final scaffoldBg = const Color(0xFFF5F5F5);
    final cardBg = Colors.white;

    final baseTextTheme = GoogleFonts.interTextTheme();
    final textTheme = baseTextTheme.apply(
      bodyColor: textColor,
      displayColor: textColor,
    );

    final theme = ThemeData(
      useMaterial3: false,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: primary,
        surface: cardBg,
        background: scaffoldBg,
        onPrimary: Colors.white,
        onSurface: textColor,
      ),
      scaffoldBackgroundColor: scaffoldBg,
      cardColor: cardBg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textColor,
        elevation: 0,
        titleTextStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      iconTheme: IconThemeData(color: textColor),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      initialRoute: '/welcome',
      routes: {
        // Routes publiques
        '/welcome': (context) => const WelcomeScreen(),
        '/stepper': (context) => const StepperScreen(),
        '/auth/register': (context) => const RegisterPage(),
        '/auth/login': (context) => const LoginPage(),
        '/auth/otp': (context) {
          final phone = ModalRoute.of(context)?.settings.arguments as String? ?? '';
          return OtpPage(phone: phone);
        },
        
        // Routes protégées
        '/home': (context) => AuthGuard(child: const HomePage()),
        '/user_dashboard/home': (context) => AuthGuard(child: const HomePage()),
        '/soil_analysis/detection_capteurs': (context) => AuthGuard(child: const DetectionCapteursPage()),
        '/soil_analysis/analysis': (context) => AuthGuard(child: const AnalysisScreen()),
        '/soil_analysis/crop_detail': (context) => AuthGuard(child: const CropDetailScreen()),
      },
    );
  }
}
