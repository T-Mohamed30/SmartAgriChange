import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/analysis_simple.dart';
import '../providers/dashboard_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart'; // Assurez-vous que ce chemin est correct

// --- CONSTANTES DE FORMATAGE ---
final _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');

// --- PROVIDER ---

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
    debugPrint(
      '⚠️ HistoriqueScreen: No userId found in SharedPreferences. Returning empty list.',
    );
    // Vous pourriez aussi lancer une exception ici si l'absence d'ID est critique.
    return [];
  }

  // Utilisation de .toString() pour s'assurer que le repository reçoit une String
  final analyses = await repository.fetchUserAnalyses(userId.toString());
  debugPrint(
    '📊 HistoriqueScreen: Received ${analyses.length} analyses from repository',
  );

  return analyses;
});

// --- ÉCRAN ---

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
    // Utilisation de Navigator.of(context) pour plus de robustesse
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed('/user_dashboard/home');
    } else if (index == 1) {
      Navigator.of(context).pushReplacementNamed('/soil_analysis/champs');
    } else if (index == 3) {
      Navigator.of(context).pushReplacementNamed('/account');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Le Consumer n'est pas nécessaire ici car le widget est un ConsumerStatefulWidget
    // et utilise ref.watch() dans la méthode build
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
          // Invalider le provider pour forcer un nouveau fetch
          ref.invalidate(allAnalysesProvider);
        },
        child: analysesAsync.when(
          data: (analyses) => analyses.isEmpty
              ? Center(
                  // Utilisation d'un ListView pour permettre le "pull to refresh" même si la liste est vide
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 150),
                      Text(
                        'Aucune analyse trouvée',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'Erreur de chargement: ${error.toString()}',
                    textAlign: TextAlign.center,
                  ),
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
      ),
      // La BottomNavigationBar reste inchangée
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
          ),
        ),
      ),
    );
  }

  // Widgets de navigation (inchangés, mais pourraient être extraits)
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

  // --- WIDGET D'ANALYSE AMÉLIORÉ ---
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

    // Couleur du statut et libellé
    Color statusColor;
    String statusLabel;

    switch (analysis.status) {
      case AnalysisStatus.completed:
        if (analysis.type == 'plant') {
          // Logique spécifique pour analyse de plante terminée
          if (analysis.result != null &&
              analysis.result != 'Aucune anomalie détectée') {
            statusColor = Colors.red.shade700; // Couleur rouge plus foncée
            statusLabel = analysis.result!;
          } else {
            statusColor = Colors.green.shade600; // Couleur verte
            statusLabel = 'Saine';
          }
        } else {
          // Statut terminé pour analyse de sol ou autre
          statusColor = const Color(0xFF007F3D);
          statusLabel = 'Terminé';
        }
        break;
      case AnalysisStatus.pending:
        statusColor = Colors.orange;
        statusLabel = 'En cours';
        break;
      case AnalysisStatus.failed:
        statusColor = Colors.red;
        statusLabel = 'Échouée';
        break;
      // Ajoutez un cas 'default' si nécessaire pour couvrir toutes les possibilités
      default:
        statusColor = Colors.grey;
        statusLabel = 'Inconnu';
    }

    return GestureDetector(
      onTap: () {
        // Navigation vers les détails de l'analyse
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Afficher les détails de ${analysis.name.split('___').first}',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 10,
        ), // Légère augmentation de la marge
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.08,
              ), // Ombre un peu plus visible
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: analysis.imageUrl != null && analysis.type == 'plant'
              ? Container(
                  width: 50, // Légèrement plus grand
                  height: 50, // Légèrement plus grand
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(analysis.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: itemColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 24),
                    ), // Icône plus grande
                  ),
                ),
          title: Text(
            analysis.name.split('___').first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700, // Plus gras pour le titre
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                analysis.location,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                typeLabel,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    // Utilisation du formateur constant
                    _dateTimeFormatter.format(analysis.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  const SizedBox(width: 8),
                  // --- MODIFICATION DEMANDÉE : PASTILLE PLUS GRANDE ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, // Augmenté
                      vertical: 3, // Augmenté
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Rayon plus grand
                    ),
                    child: Text(
                      statusLabel,
                      style: const TextStyle(
                        fontSize: 10, // Augmenté pour la lisibilité
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // --------------------------------------------------
                ],
              ),
              if (analysis.parcelle != null &&
                  analysis.parcelle!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'Parcelle: ${analysis.parcelle}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ],
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.grey.shade400,
            size: 24, // Légèrement plus grand
          ),
        ),
      ),
    );
  }
}
