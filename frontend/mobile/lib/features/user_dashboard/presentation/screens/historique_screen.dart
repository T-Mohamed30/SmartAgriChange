import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/analysis_simple.dart';
import '../providers/dashboard_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Provider pour toutes les analyses de l'utilisateur
final allAnalysesProvider = FutureProvider<List<Analysis>>((ref) async {
  debugPrint('📱 HistoriqueScreen: Starting allAnalysesProvider');

  final repository = ref.read(analysisRepositoryProvider);
  // Récupérer l'ID utilisateur depuis SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('user_id');

  debugPrint(
    '👤 HistoriqueScreen: Retrieved userId from SharedPreferences: $userId',
  );

  if (userId == null) {
    debugPrint('⚠️ HistoriqueScreen: No userId found in SharedPreferences');
    return [];
  }

  final analyses = await repository.fetchUserAnalyses(userId.toString());
  debugPrint(
    '📊 HistoriqueScreen: Received ${analyses.length} analyses from repository',
  );

  return analyses;
});

class HistoriqueScreen extends ConsumerStatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  ConsumerState<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends ConsumerState<HistoriqueScreen> {
  int _selectedIndex = 2; // Historique is index 2

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      // Navigate to Home
      Navigator.pushReplacementNamed(context, '/user_dashboard/home');
    } else if (index == 1) {
      // Navigate to Champs
      Navigator.pushReplacementNamed(context, '/soil_analysis/champs');
    } else if (index == 3) {
      // Navigate to Account
      Navigator.pushReplacementNamed(context, '/account');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final analysesAsync = ref.watch(allAnalysesProvider);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text('Historique des analyses'),
            foregroundColor: Colors.black,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(allAnalysesProvider);
            },
            child: analysesAsync.when(
              data: (analyses) => analyses.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucune analyse trouvée',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: analyses.length,
                      itemBuilder: (context, index) {
                        final analysis = analyses[index];
                        return _buildAnalysisCard(context, analysis);
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
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
                      onPressed: () => ref.invalidate(allAnalysesProvider),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: SizedBox(
              height: 105,
              child: BottomNavigationBar(
                backgroundColor: Colors.white,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                items: [
                  BottomNavigationBarItem(
                    icon: _navTile('assets/icons/home.png', 'Accueil'),
                    activeIcon: _navTileActive(
                      'assets/icons/home.png',
                      'Accueil',
                    ),
                    label: 'Accueil',
                  ),
                  BottomNavigationBarItem(
                    icon: _navTile('assets/icons/map.png', 'Champs'),
                    activeIcon: _navTileActive(
                      'assets/icons/map.png',
                      'Champs',
                    ),
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
                    activeIcon: _navTileActive(
                      'assets/icons/profil.png',
                      'Compte',
                    ),
                    label: 'Compte',
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF007F3D),
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

  Widget _buildAnalysisCard(BuildContext context, Analysis analysis) {
    // Détermine la couleur et l'icône selon le type
    Color itemColor;
    String icon;
    String typeLabel;

    switch (analysis.type) {
      case 'soil':
        itemColor = Colors.orange.shade100;
        icon = '🌾';
        typeLabel = 'Analyse du sol';
        break;
      case 'plant':
        itemColor = Colors.green.shade100;
        icon = '🌱';
        typeLabel = 'Analyse de plante';
        break;
      default:
        itemColor = Colors.grey.shade100;
        icon = '📊';
        typeLabel = 'Analyse';
    }

    // Couleur du statut
    Color statusColor;
    String statusLabel;
    switch (analysis.status) {
      case AnalysisStatus.completed:
        statusColor = const Color(0xFF007F3D);
        statusLabel = 'Terminée';
        break;
      case AnalysisStatus.pending:
        statusColor = Colors.orange;
        statusLabel = 'En cours';
        break;
      case AnalysisStatus.failed:
        statusColor = Colors.red;
        statusLabel = 'Échouée';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(
        bottom: 8,
      ), // Réduire la marge pour des cartes plus compactes
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
        contentPadding: const EdgeInsets.all(12), // Réduire le padding
        leading: Container(
          width: 40, // Réduire la taille
          height: 40,
          decoration: BoxDecoration(
            color: itemColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ), // Réduire la taille de l'icône
          ),
        ),
        title: Text(
          analysis.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ), // Réduire la taille du texte
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              analysis.location,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 1),
            Text(
              typeLabel,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 1),
            Row(
              children: [
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(analysis.createdAt),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 8,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (analysis.parcelle != null) ...[
              const SizedBox(height: 1),
              Text(
                'Parcelle: ${analysis.parcelle}',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
          size: 20,
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
}
