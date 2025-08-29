import '../soil_analysis/presentation/champs_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smartagrichange_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smartagrichange_mobile/features/weather/domain/entities/weather_entity.dart';
import 'package:smartagrichange_mobile/features/weather/presentation/providers/weather_provider.dart'
    as weather_provider;
import 'domain/entities/analysis_simple.dart';
import 'package:smartagrichange_mobile/features/user_dashboard/presentation/providers/dashboard_provider.dart';
import 'package:smartagrichange_mobile/features/user_dashboard/presentation/providers/dashboard_provider.dart'
    show dashboardStatsProvider, recentAnalysesProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../soil_analysis/presentation/champs_list_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAnalyzeBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildAnalyzeBottomSheet(),
    );
  }

  void goToDetectionCapteurs() {
    Navigator.pushReplacementNamed(
      context,
      '/soil_analysis/detection_capteurs',
    );
  }

  Future<void> _onRefresh() async {
    // Refresh logic will be implemented here
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_selectedIndex) {
      case 1:
        page = ChampsListPage();
        break;
      default:
        page = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(child: _buildRecentAnalysis()),
          ],
        );
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(child: page),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _showAnalyzeBottomSheet,
              backgroundColor: Color(0xFF007F3D),
              shape: CircleBorder(),
              child: Image.asset('assets/icons/plus.png', color: Colors.white),
              elevation: 8,
            )
          : null,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: SizedBox(height: 105, child: _buildBottomNavigationBar()),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer(
                    builder: (context, ref, _) {
                      final user = ref.watch(userProvider);
                      final hour = DateTime.now().hour;

                      // Récupérer le prénom de manière sécurisée
                      final prenom = user!.prenom;
                      final displayName = prenom.isNotEmpty
                          ? prenom
                          : 'Utilisateur';

                      // Déterminer la salutation en fonction de l'heure
                      final greeting = hour < 12 ? 'Bonjour' : 'Bonsoir';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Prêt à booster votre prochaine récolte ?',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Image.asset(
                  'assets/icons/cloche.png',
                  color: Colors.black,
                  height: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weather Card
          Consumer(
            builder: (context, ref, _) {
              final weatherAsync = ref.watch(weather_provider.weatherProvider);

              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F1FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                height: 110,
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () =>
                            ref.refresh(weather_provider.weatherProvider),
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Image.asset(
                            'assets/icons/reload.png',
                            height: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: weatherAsync.when(
                          data: (weather) {
                            try {
                              // Sélectionner l'icône en fonction des conditions météo
                              String weatherIcon =
                                  'assets/icons/temps_1.png'; // Par défaut
                              final condition =
                                  weather.condition?.toLowerCase() ?? '';

                              if (condition.contains('pluie') ||
                                  condition.contains('rain')) {
                                weatherIcon = 'assets/icons/temps_5.png';
                              } else if (condition.contains('nuage') ||
                                  condition.contains('cloud')) {
                                weatherIcon = 'assets/icons/temps_2.png';
                              } else if (condition.contains('orage') ||
                                  condition.contains('thunder')) {
                                weatherIcon = 'assets/icons/temps_3.png';
                              }

                              return Image.asset(
                                weatherIcon,
                                height: 64,
                                width: 64,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                      'assets/icons/temps_1.png',
                                      height: 64,
                                      width: 64,
                                    ),
                              );
                            } catch (e) {
                              return Image.asset(
                                'assets/icons/temps_1.png',
                                height: 64,
                                width: 64,
                              );
                            }
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stackTrace) {
                            print('Erreur météo: $error');
                            return const Text('Météo non disponible');
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 118),
                        child: weatherAsync.when(
                          data: (weather) => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${weather.temperature.toStringAsFixed(1)}°C',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                weather.condition,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Text(
                                weather.location,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                'Mise à jour: ${DateFormat('HH:mm').format(weather.lastUpdated)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stack) => Text(
                            'Erreur météo',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Irrigation Reminder
          Container(
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(color: Colors.red.shade400, width: 4),
              ),
            ),
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Image.asset(
                  'assets/icons/interface-alert-information-circle--information-frame-info-more-help-point-circle--Streamline-Core.png',
                  height: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Penser à irriguer la parcelle 2 ce soir.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats
          Consumer(
            builder: (context, ref, child) {
              final statsAsync = ref.watch(dashboardStatsProvider);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: statsAsync.when(
                  data: (stats) => Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: _buildStatItem(
                            stats['capteurs']?.toString() ?? '0',
                            'Capteurs actifs',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: _buildStatItem(
                            stats['champs']?.toString() ?? '0',
                            'Champs',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: _buildStatItem(
                            stats['alertes']?.toString() ?? '0',
                            'Alertes',
                          ),
                        ),
                      ),
                    ],
                  ),
                  loading: () => const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ),
                  error: (error, stack) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('--', 'Capteurs'),
                      _buildStatItem('--', 'Champs'),
                      _buildStatItem('--', 'Alertes'),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(dynamic value, String label) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF007F3D),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentAnalysis() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        height: 320,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Les analyses récentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final analysesAsync = ref.watch(recentAnalysesProvider);

                  return analysesAsync.when(
                    data: (analyses) => ListView.separated(
                      itemCount: analyses.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: Colors.grey.shade200),
                      itemBuilder: (context, index) {
                        final analysis = analyses[index];
                        // type icon bg color
                        Color itemColor;
                        String icon;
                        switch (analysis.type) {
                          case 'soil':
                            itemColor = Colors.orange.shade100;
                            icon = '🌾';
                            break;
                          case 'plant':
                            itemColor = Colors.green.shade100;
                            icon = '🌱';
                            break;
                          default:
                            itemColor = Colors.grey.shade100;
                            icon = '📊';
                        }
                        // status color
                        Color statusColor;
                        switch (analysis.status) {
                          case AnalysisStatus.completed:
                            statusColor = const Color(0xFF007F3D);
                            break;
                          case AnalysisStatus.pending:
                            statusColor = Colors.orange;
                            break;
                          case AnalysisStatus.failed:
                            statusColor = Colors.red;
                            break;
                        }

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 6,
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: itemColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                icon,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          title: Text(
                            analysis.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            analysis.location,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (analysis.parcelle != null)
                                Text(
                                  analysis.parcelle ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Détails de ${analysis.name}'),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text('Erreur de chargement: $error'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () =>
                                ref.refresh(recentAnalysesProvider),
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisItem(Analysis analysis) {
    // Détermine la couleur et l'icône selon le type
    Color itemColor;
    String icon;

    switch (analysis.type) {
      case 'soil':
        itemColor = Colors.orange.shade100;
        icon = '🌾';
        break;
      case 'plant':
        itemColor = Colors.green.shade100;
        icon = '🌱';
        break;
      default:
        itemColor = Colors.grey.shade100;
        icon = '📊';
    }

    // Couleur du statut
    Color statusColor;
    switch (analysis.status) {
      case AnalysisStatus.completed:
        statusColor = const Color(0xFF007F3D);
        break;
      case AnalysisStatus.pending:
        statusColor = Colors.orange;
        break;
      case AnalysisStatus.failed:
        statusColor = Colors.red;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: itemColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
        ),
        title: Text(
          analysis.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          analysis.location,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (analysis.parcelle != null)
              Text(
                analysis.parcelle!,
                style: TextStyle(fontSize: 14, color: statusColor),
              ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
        onTap: () {
          // Navigation vers les détails de l'analyse
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Détails de ${analysis.name}')),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        BottomNavigationBarItem(
          icon: _navTile('assets/icons/home.png', 'Accueil'),
          activeIcon: _navTileActive('assets/icons/home.png', 'Accueil'),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: _navTile('assets/icons/map.png', 'Champs'),
          activeIcon: _navTileActive('assets/icons/map.png', 'Champs'),
          label: 'Champs',
        ),
        BottomNavigationBarItem(
          icon: _navTile('assets/icons/historique.png', 'Historique'),
          activeIcon: _navTileActive(
            'assets/icons/historique.png',
            'Historique',
          ),
          label: 'Historique',
        ),
        BottomNavigationBarItem(
          icon: _navTile('assets/icons/profil.png', 'Compte'),
          activeIcon: _navTileActive('assets/icons/profil.png', 'Compte'),
          label: 'Compte',
        ),
      ],
    );
  }

  Widget _navTile(String asset, String label) {
    return Container(
      width: 72,
      height: 72,
      color: Colors.white,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(asset, height: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navTileActive(String asset, String label) {
    return Container(
      width: 72,
      height: 72,
      // color: const Color(0xFF007F3D),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color(0xFF007F3D),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(asset, height: 24, color: Colors.white),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeBottomSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 100,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 24),

            // Analyze soil button
            Center(
              child: SizedBox(
                width: 400,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007F3D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: goToDetectionCapteurs,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.science_outlined, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Analyser le sol',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Scan plant button
            Center(
              child: SizedBox(
                width: 400,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Scanne de plante démarr��e'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5F8EC),
                    foregroundColor: const Color(0xFF007F3D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Scanner la plante',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
