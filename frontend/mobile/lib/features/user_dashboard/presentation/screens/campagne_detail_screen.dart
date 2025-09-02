import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smartagri_mobile/features/user_dashboard/presentation/providers/providers.dart';
import 'package:smartagri_mobile/features/user_dashboard/domain/entities/entities.dart';

class CampagneDetailScreen extends ConsumerWidget {
  final String campagneId;
  
  const CampagneDetailScreen({super.key, required this.campagneId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campagneAsync = ref.watch(campagneDetailProvider(campagneId));
    
    return Scaffold(
      appBar: AppBar(
        title: campagneAsync.when(
          data: (campagne) => Text('Campagne: ${campagne.nom}'),
          loading: () => const Text('Chargement...'),
          error: (error, _) => const Text('Erreur de chargement'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(campagneDetailProvider(campagneId)),
          ),
        ],
      ),
      body: campagneAsync.when(
        data: (campagne) => _buildCampagneDetail(campagne, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erreur: $error')),
      ),
    );
  }

  Widget _buildCampagneDetail(Campagne campagne, WidgetRef ref) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec les informations générales
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        campagne.nom,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Chip(
                        label: Text(
                          _getStatusLabel(campagne.statut),
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: _getStatusColor(campagne.statut),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Parcelle: ${campagne.parcelle?.nom ?? 'Non spécifiée'}'),
                  Text('Culture: ${campagne.culture?.nom ?? 'Non spécifiée'}'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: campagne.progression / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Progression: ${campagne.progression}%'),
                  const SizedBox(height: 8),
                  Text('Début: ${dateFormat.format(campagne.dateDebut)}'),
                  if (campagne.dateFinPrevue != null)
                    Text('Fin prévue: ${dateFormat.format(campagne.dateFinPrevue!)}'),
                  if (campagne.notes?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 8),
                    Text('Notes: ${campagne.notes}'),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Liste des étapes
          Text(
            'Étapes de la campagne',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...campagne.etapes?.map((etape) => _buildEtapeCard(etape, ref)) ?? [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Aucune étape disponible'),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Bouton pour démarrer/continuer la campagne
          if (campagne.statut == 'en_attente' || campagne.statut == 'en_cours')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Logique pour démarrer/continuer la campagne
                  _showNextStepsDialog(context, campagne, ref);
                },
                child: Text(
                  campagne.statut == 'en_attente' 
                      ? 'Démarrer la campagne' 
                      : 'Voir les prochaines étapes',
                ),
              ),
            ),
            
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildEtapeCard(EtapeCampagne etape, WidgetRef ref) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        title: Text(etape.nom),
        subtitle: Text('${etape.statut.toString().split('.').last} - ${etape.taches?.length ?? 0} tâches'),
        leading: CircleAvatar(
          backgroundColor: _getEtapeStatusColor(etape.statut),
          child: Text(
            '${etape.ordre}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (etape.description?.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(etape.description!),
                  ),
                Text('Durée: ${etape.dureeJours} jours'),
                Text('Début: ${dateFormat.format(etape.dateDebut)}'),
                Text('Fin: ${dateFormat.format(etape.dateFin)}'),
                
                const SizedBox(height: 16),
                
                // Liste des tâches
                const Text(
                  'Tâches:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...etape.taches?.map((tache) => _buildTacheItem(tache, ref)) ?? [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Aucune tâche disponible'),
                  ),
                ],
                
                const SizedBox(height: 8),
                
                // Bouton pour marquer l'étape comme terminée
                if (etape.statut != StatutEtape.terminee)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _updateEtapeStatus(
                          context,
                          etape.id,
                          etape.campagneId,
                          StatutEtape.terminee.toString().split('.').last,
                          ref,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Marquer comme terminée'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTacheItem(Tache tache, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Checkbox(
          value: tache.statut == StatutTache.terminee,
          onChanged: (value) {
            final newStatus = value == true 
                ? StatutTache.terminee.toString().split('.').last
                : StatutTache.aFaire.toString().split('.').last;
                
            ref.read(updateTacheStatusProvider({
              'tacheId': tache.id,
              'statut': newStatus,
              'campagneId': tache.etapeCampagneId,
            }).future);
          },
        ),
        title: Text(tache.description),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Priorité: ${_getPriorityLabel(tache.priorite)}'),
            if (tache.materielRequis?.isNotEmpty ?? false)
              Text('Matériel: ${tache.materielRequis!.join(', ')}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              // Logique de suppression
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Text('Supprimer'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _updateEtapeStatus(
    BuildContext context,
    String etapeId,
    String campagneId,
    String newStatus,
    WidgetRef ref,
  ) {
    ref.read(updateEtapeStatusProvider({
      'etapeId': etapeId,
      'statut': newStatus,
      'campagneId': campagneId,
    }).future);
  }
  
  void _showNextStepsDialog(BuildContext context, Campagne campagne, WidgetRef ref) {
    final prochainesEtapes = campagne.etapes
        ?.where((etape) => etape.statut == StatutEtape.aFaire)
        .toList()
        .sublist(0, 3) ?? [];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prochaines étapes'),
        content: prochainesEtapes.isEmpty
            ? const Text('Aucune étape à venir')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Voici les prochaines étapes à réaliser:'),
                  const SizedBox(height: 16),
                  ...prochainesEtapes.map((etape) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('• ${etape.nom} (${etape.dateDebut.day}/${etape.dateDebut.month})'),
                  )),
                ],
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          if (prochainesEtapes.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Logique pour démarrer la première étape
                if (prochainesEtapes.isNotEmpty) {
                  _updateEtapeStatus(
                    context,
                    prochainesEtapes.first.id,
                    campagne.id,
                    StatutEtape.enCours.toString().split('.').last,
                    ref,
                  );
                }
              },
              child: const Text('Commencer la première étape'),
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
  
  Color _getEtageStatusColor(StatutEtape status) {
    switch (status) {
      case StatutEtape.aFaire:
        return Colors.grey;
      case StatutEtape.enCours:
        return Colors.blue;
      case StatutEtape.terminee:
        return Colors.green;
      case StatutEtape.enRetard:
        return Colors.red;
    }
  }
  
  String _getPriorityLabel(PrioriteTache priorite) {
    switch (priorite) {
      case PrioriteTache.basse:
        return 'Basse';
      case PrioriteTache.moyenne:
        return 'Moyenne';
      case PrioriteTache.haute:
        return 'Haute';
      case PrioriteTache.critique:
        return 'Critique';
    }
  }
}
