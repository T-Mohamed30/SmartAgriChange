import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'package:smartagrichange_mobile/core/auth/auth_guard.dart';
import 'package:smartagrichange_mobile/features/weather/presentation/providers/weather_provider.dart';
import 'package:smartagrichange_mobile/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/presentation/detection_capteurs.dart';
import 'package:smartagrichange_mobile/features/user_dashboard/home.dart';
import 'package:smartagrichange_mobile/features/plant_analysis/models/anomaly_analysis_models.dart';
import 'features/onboarding/presentation/welcome_screen.dart';
import 'features/onboarding/presentation/stepper_screen.dart';
import 'features/auth/presentation/register.dart';
import 'package:smartagrichange_mobile/features/auth/presentation/login.dart';
import 'features/auth/presentation/otp_page.dart';
import 'features/soil_analysis/presentation/analysis_screen.dart';
import 'features/soil_analysis/presentation/crop_detail_screen.dart';
import 'features/soil_analysis/presentation/crop_calendar_screen.dart';
import 'features/account/presentation/account_page.dart';
import 'features/plant_analysis/presentation/plant_scanner_screen.dart';
import 'features/plant_analysis/presentation/plant_detail_page.dart';
import 'features/plant_analysis/presentation/plant_full_detail_page.dart';

void main() async {
  // Clear all stored data on app start for clean authentication state
  WidgetsFlutterBinding.ensureInitialized();

  // Force synchronous clearing of all stored data
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Clear all stored data including tokens

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
    const primary = Color(0xFF007F3D);
    const textColor = Color(0xFF333333);
    const scaffoldBg = Color(0xFFF5F5F5);
    const cardBg = Colors.white;

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
        backgroundColor: scaffoldBg,
        foregroundColor: textColor,
        elevation: 0,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
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
        '/auth/login': (context) => LoginPage(),
        '/auth/otp': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic>) {
            final phone = args['phone'] as String? ?? '';
            final userId = args['user_id'] as int?;
            return OtpPage(phone: phone, userId: userId);
          } else if (args is String) {
            // Fallback for old string argument
            return OtpPage(phone: args);
          }
          return const OtpPage(phone: '');
        },
        '/account': (context) => const AccountPage(),

        // Routes protégées
        '/home': (context) => const AuthGuard(child: HomePage()),
        '/user_dashboard/home': (context) => const AuthGuard(child: HomePage()),
        '/soil_analysis/detection_capteurs': (context) =>
            const AuthGuard(child: DetectionCapteursPage()),
        '/soil_analysis/analysis': (context) =>
            const AuthGuard(child: AnalysisScreen()),
        '/soil_analysis/crop_detail': (context) =>
            const AuthGuard(child: CropDetailScreen()),
        '/soil_analysis/calendar': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          return AuthGuard(child: CropCalendarScreen(key: UniqueKey()));
        },
        '/plant_analysis/scanner': (context) =>
            const AuthGuard(child: PlantScannerScreen()),
        '/plant_analysis/detail': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          final analysisResult =
              args['analysisResult'] as AnomalyAnalysisResponse?;
          final imageBytes = args['imageBytes'] as Uint8List?;
          return AuthGuard(
            child: PlantDetailPage(
              analysisResult: analysisResult,
              imageBytes: imageBytes,
            ),
          );
        },
        '/plant_analysis/full_detail': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {};
          final analysisResult =
              args['analysisResult'] as AnomalyAnalysisResponse?;
          final imageBytes = args['imageBytes'] as Uint8List?;
          return AuthGuard(
            child: PlantFullDetailPage(
              analysisResult: analysisResult,
              imageBytes: imageBytes,
            ),
          );
        },
      },
    );
  }
}
