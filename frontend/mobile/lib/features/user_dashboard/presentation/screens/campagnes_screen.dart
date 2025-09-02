import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smartagri_mobile/features/user_dashboard/presentation/providers/providers.dart';
import 'package:smartagri_mobile/features/user_dashboard/domain/entities/entities.dart';
import 'package:smartagri_mobile/features/user_dashboard/presentation/screens/campagne_detail_screen.dart';

class CampagnesScreen extends ConsumerStatefulWidget {
  const CampagnesScreen({super.key});

  @override
  ConsumerState<CampagnesScreen> createState() => _CampagnesScreenState();
}

class _CampagnesScreenState extends ConsumerState<CampagnesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statusTabs = ['Toutes', 'En attente', 'En cours', 'Terminées', 'Annulées'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Campagnes Agricoles'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _statusTabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _statusTabs.map((status) {
          return _buildCampagnesList(status);
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigation vers l'écran de création d'une nouvelle campagne
          _showNouvelleCampagneDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildCampagnesList(String status) {
    final String? statusFilter = status == 'Toutes' 
        ? null 
        : status.toLowerCase().replaceAll('é', 'e').replaceAll(' ', '_');
    
    final campagnesAsync = ref.watch(campagnesProvider(statusFilter));
    
    return campagnesAsync.when(
      data: (campagnes) {
        if (campagnes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.agriculture, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Aucune campagne ${status.toLowerCase() != 'toutes' ? status.toLowerCase() : ''} trouvée',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (status == 'Toutes')
                  ElevatedButton(
                    onPressed: () {
                      _showNouvelleCampagneDialog(context, ref);
                    },
                    child: const Text('Créer une campagne'),
                  ),
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(campagnesProvider(statusFilter));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: campagnes.length,
            itemBuilder: (context, index) {
              final campagne = campagnes[index];
              return _buildCampagneCard(campagne);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement des campagnes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(campagnesProvider(statusFilter));
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCampagneCard(Campagne campagne) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CampagneDetailScreen(campagneId: campagne.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      campagne.nom,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(
                    label: Text(
                      _getStatusLabel(campagne.statut),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: _getStatusColor(campagne.statut),
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Parcelle: ${campagne.parcelle?.nom ?? 'Non spécifiée'}'),
              Text('Culture: ${campagne.culture?.nom ?? 'Non spécifiée'}'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: campagne.progression / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${campagne.progression}%'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Début: ${dateFormat.format(campagne.dateDebut)}'),
                  if (campagne.dateFinPrevue != null)
                    Text('Fin: ${dateFormat.format(campagne.dateFinPrevue!)}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showNouvelleCampagneDialog(BuildContext context, WidgetRef ref) {
    // TODO: Implémenter la logique de création d'une nouvelle campagne
    // Ceci est un exemple de base, à adapter selon vos besoins
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle Campagne Agricole'),
        content: const Text('Sélectionnez une analyse de sol pour commencer une nouvelle campagne.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implémenter la navigation vers la sélection d'analyse
              Navigator.pop(context);
              // Navigator.push(...);
            },
            child: const Text('Sélectionner une analyse'),
          ),
        ],
      ),
    );
  }
  
  String _getStatusLabel(String status) {
    switch (status) {
      case 'en_attente':
        return 'En attente';
      case 'en_cours':
        return 'En cours';
      case 'terminee':
        return 'Terminée';
      case 'annulee':
        return 'Annulée';
      default:
        return status;
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'en_attente':
        return Colors.orange;
      case 'en_cours':
        return Colors.blue;
      case 'terminee':
        return Colors.green;
      case 'annulee':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
