import 'dart:async';
import 'package:flutter/material.dart';
import '../../soil_analysis/presentation/widgets/action_button.dart';

class StepperScreen extends StatefulWidget {
  const StepperScreen({super.key});

  @override
  State<StepperScreen> createState() => _StepperScreenState();
}

class _StepperScreenState extends State<StepperScreen> {
  int currentIndex = 0;
  Timer? _timer;
  final PageController _pageController = PageController();

  final List<Map<String, String>> steps = [
    {
      'image': 'assets/images/stepper_img_1.png',
      'title': 'Boostez vos récoltes avec l’intelligence artificielle',
      'content':
          'Notre application transforme vos données de terrain en conseils pratiques pour améliorer vos rendements.',
    },
    {
      'image': 'assets/images/stepper_img_2.png',
      'title': 'Comprenez votre sol comme jamais',
      'content':
          'Grâce à notre capteur, nous recueillons des données précises sur votre sol et vous donnons des recommandations personnalisées pour optimiser vos cultures',
    },
    {
      'image': 'assets/images/stepper_img_3.png',
      'title': 'Identifiez les maladies des plantes en un instant',
      'content':
          'Prenez une photo de vos plantes et laissez notre IA détecter les anomalies pour agir rapidement.',
    },
    {
      'image': 'assets/images/stepper_img_4.png',
      'title': 'Prêt à améliorer votre productivité ?',
      'content':
          'Créez votre compte et profitez dès aujourd’hui de nos outils intelligents pour vos champs.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        final nextIndex = (currentIndex + 1) % steps.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoPlay() {
    _timer?.cancel();
  }

  void _resumeAutoPlay() {
    _stopAutoPlay();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void goToAuth() {
    Navigator.pushReplacementNamed(context, '/auth/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                  _resumeAutoPlay();
                },
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return GestureDetector(
                    onTap: _stopAutoPlay,
                    onPanDown: (_) => _stopAutoPlay(),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Image.asset(
                            step['image']!,
                            semanticLabel: 'Illustration étape ${index + 1}',
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  step['title']!,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  step['content']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Indicateurs avec navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(
                  steps.length,
                  (index) => GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      _resumeAutoPlay();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: index == currentIndex ? 24 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: index == currentIndex
                            ? Colors.green
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ActionButton(text: 'Sauter', onPressed: goToAuth),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
