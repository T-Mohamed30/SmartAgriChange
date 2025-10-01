import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import '../application/analysis_service.dart';

class AnalysisArgs {
  final String sensorId;
  final String sensorName;
  final String? champName;
  final String? parcelleName;
  const AnalysisArgs({
    required this.sensorId,
    required this.sensorName,
    this.champName,
    this.parcelleName,
  });
}

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Auto-redirect to data display after loading
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _showResults = true;
      });
      _controller.stop();
      // Trigger data simulation and AI call
      ref.read(analysisServiceProvider).fetchDataAndAnalyze();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDataDisplay(AnalysisArgs? args) {
    final recommendations = ref.watch(recommendationsProvider);
    final soilData = ref.watch(soilDataProvider);
    return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (args != null) ...[
                Text(
                  args.champName == null
                      ? 'Capteur: ${args.sensorName}'
                      : 'Capteur: ${args.sensorName} • Champ: ${args.champName}${args.parcelleName != null ? ' • Parcelle: ${args.parcelleName}' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 16),
              ],

              _metricRow('Conductivité', soilData != null ? '${soilData.ec.toStringAsFixed(1)} us/cm' : '0 us/cm', 'assets/icons/renewable-energy 1.png'),
              const SizedBox(height: 16),
              _metricRow('Température', soilData != null ? '${soilData.temperature.toStringAsFixed(1)} °C' : '0 °C', 'assets/icons/celsius 1.png'),
              const SizedBox(height: 16),
              _metricRow('Humidité', soilData != null ? '${soilData.humidity.toStringAsFixed(1)} %' : '0 %', 'assets/icons/humidity 1.png'),
              const SizedBox(height: 16),
              _metricRow('Ph', soilData != null ? soilData.ph.toStringAsFixed(1) : '0', 'assets/icons/ph.png'),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/icons/npk-illustration.png', width: 24, height: 24, fit: BoxFit.contain),
                        const SizedBox(width: 8),
                        const Text('Nutriments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Azote (N)'),
                              SizedBox(height: 4),
                              Text(soilData != null ? '${soilData.nitrogen.toStringAsFixed(0)} mg/kg' : '0 mg/kg', style: TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Phosphore (P)'),
                              SizedBox(height: 4),
                              Text(soilData != null ? '${soilData.phosphorus.toStringAsFixed(0)} mg/kg' : '0 mg/kg', style: TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Potassium (K)'),
                              SizedBox(height: 4),
                              Text(soilData != null ? '${soilData.potassium.toStringAsFixed(0)} mg/kg' : '0 mg/kg', style: TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Descrpition', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus. Suspendisse lectus tortor, dignissim sit amet, adipiscing nec, ultricies sed, dolor.',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nos Recommendations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Expanded(
                        child: recommendations.isEmpty
                          ? const Center(child: Text('Chargement des recommandations...'))
                          : ListView.separated(
                              itemCount: recommendations.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final item = recommendations[index];
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5F8EC),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.culture.name,
                                              style: const TextStyle(fontWeight: FontWeight.w700),
                                            ),
                                            const SizedBox(height: 2),
                                            Text('compatibilité: ${item.compatibilityScore.toStringAsFixed(1)}%'),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/soil_analysis/crop_detail',
                                            arguments: item.culture.name,
                                          );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(Icons.chevron_right, color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
  }

  Widget _metricTile(String label, String value, String asset) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(asset, width: 32, height: 32, fit: BoxFit.contain),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricRow(String label, String value, String asset) {
    return Row(
      children: [
        Image.asset(asset, width: 24, height: 24, fit: BoxFit.contain),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as AnalysisArgs?;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _showResults
          ? AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              centerTitle: true,
              title: const Text('Résultat', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
              leadingWidth: 64,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.black),
            )
          : null,
            body: SafeArea(
        top: !_showResults,
        child: _showResults ? _buildDataDisplay(args) : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Zone d'animation
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 360,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Image de sol centrée et agrandie
                    final solWidth = constraints.maxWidth * 0.85;
                    final double solHeight = solWidth / 2;

                    // Centre horizontal
                    final double cx = constraints.maxWidth / 2;
                    // Rayon de la courbe des icônes (au-dessus du sol)
                    final double R = solWidth * 0.45;
                    // Décalage vertical de base (les icônes collent la surface)
                    final double baseOffset = solHeight - 6;

                    // Angles en degrés (gauche -> droite) pour 5 icônes
                    final List<double> deg = [160, 125, 90, 55, 20];
                    final List<Offset> bases = deg.map((d) {
                      final rad = d * math.pi / 180.0;
                      final x = cx + R * math.cos(rad);
                      final y = baseOffset + R * math.sin(rad);
                      return Offset(x, y);
                    }).toList();

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Sol (en bas, sous les icônes)
                        Positioned(
                          bottom: 0,
                          left: (constraints.maxWidth - solWidth) / 2,
                          child: SizedBox(
                            width: solWidth,
                            height: solHeight,
                            child: Image.asset(
                              'assets/icons/sol_1.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        // 5 icônes synchronisées sur une demi-courbe
                        _FloatingIcon(
                          controller: _controller,
                          asset: 'assets/icons/npk-illustration.png',
                          baseLeft: bases[0].dx,
                          baseBottom: bases[0].dy,
                          travel: 80,
                          size: 40,
                        ),
                        _FloatingIcon(
                          controller: _controller,
                          asset: 'assets/icons/ph.png',
                          baseLeft: bases[1].dx,
                          baseBottom: bases[1].dy,
                          travel: 80,
                          size: 36,
                        ),
                        _FloatingIcon(
                          controller: _controller,
                          asset: 'assets/icons/celsius 1.png',
                          baseLeft: bases[2].dx,
                          baseBottom: bases[2].dy,
                          travel: 80,
                          size: 38,
                        ),
                        _FloatingIcon(
                          controller: _controller,
                          asset: 'assets/icons/salt 1.png',
                          baseLeft: bases[3].dx,
                          baseBottom: bases[3].dy,
                          travel: 80,
                          size: 36,
                        ),
                        _FloatingIcon(
                          controller: _controller,
                          asset: 'assets/icons/humidity 1.png',
                          baseLeft: bases[4].dx,
                          baseBottom: bases[4].dy,
                          travel: 80,
                          size: 34,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Analyse du sol en cours...",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (args != null)
                Text(
                  args.champName == null
                      ? 'Capteur: ${args.sensorName}'
                      : 'Capteur: ${args.sensorName} • Champ: ${args.champName}${args.parcelleName != null ? ' • Parcelle: ${args.parcelleName}' : ''}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  final AnimationController controller;
  final String asset;
  final double baseLeft; // position horizontale de base
  final double baseBottom; // position verticale de base (au-dessus du bas de zone)
  final double travel; // distance à parcourir vers le haut
  final double size;

  const _FloatingIcon({
    required this.controller,
    required this.asset,
    required this.baseLeft,
    required this.baseBottom,
    required this.travel,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value; // synchronisé pour toutes les icônes
        final currentBottom = baseBottom + (-t * travel);
        return Positioned(
          bottom: currentBottom,
          left: baseLeft - size / 2,
          child: Image.asset(
            asset,
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}
