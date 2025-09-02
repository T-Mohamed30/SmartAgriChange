import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/champ.dart';
import 'providers/champ_parcelle_provider.dart';
import 'detection_capteurs.dart';


// Widget ChampCard pour affichage identique à SensorCard
class ChampCard extends StatelessWidget {
  final Champ champ;
  final VoidCallback? onTap;
  const ChampCard({required this.champ, this.onTap, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              champ.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              'Localité: ${champ.location}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 10),
            ParcelleCount(champId: champ.id),
          ],
        ),
      ),
    );
  }
}

// Widget pour afficher le nombre de parcelles
class ParcelleCount extends ConsumerWidget {
  final String champId;
  const ParcelleCount({required this.champId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parcellesAsync = ref.watch(parcellesProvider(champId));
    return parcellesAsync.when(
      data: (parcelles) => Text(
        '${parcelles.length} parcelle(s)',
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
      loading: () =>
          const Text('Chargement...', style: TextStyle(fontSize: 12)),
      error: (e, _) => const Text(
        'Erreur',
        style: TextStyle(fontSize: 12, color: Colors.red),
      ),
    );
  }
}

class ChampsListPage extends ConsumerWidget {
  const ChampsListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final champsAsync = ref.watch(champsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des champs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: champsAsync.when(
                  data: (champs) => ListView.separated(
                    itemCount: champs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final champ = champs[index];
                      return Consumer(
                        builder: (context, ref, _) {
                          final parcellesAsync = ref.watch(
                            parcellesProvider(champ.id),
                          );
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ParcellesListPage(champ: champ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    champ.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        'Localité: ${champ.location}',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      parcellesAsync.when(
                                        data: (parcelles) => Text(
                                          'parcelles: ${parcelles.length}',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                        loading: () => const Text(
                                          'parcelles: ...',
                                          style: TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                        error: (e, _) => const Text(
                                          'parcelles: ?',
                                          style: TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) =>
                      Center(child: Text('Erreur: $error')),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                  child: Container(), // Placeholder for removed ElevatedButton
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const CreateChampBottomSheet(),
          );
        },
        backgroundColor: const Color(0xFF007F3D),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
        elevation: 8,
      )
    );
  }
}

class ParcellesListPage extends ConsumerWidget {
  final Champ champ;
  const ParcellesListPage({required this.champ, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parcellesAsync = ref.watch(parcellesProvider(champ.id));
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8), // espace du bord gauche et vertical

          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text('${champ.name}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: parcellesAsync.when(
                  data: (parcelles) => ListView.separated(
                    itemCount: parcelles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final parcelle = parcelles[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              parcelle.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Superficie: ${parcelle.superficie} ha',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Erreur: $error')),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => CreateParcelleBottomSheet(champId: champ.id),
          );
        },
        backgroundColor: const Color(0xFF007F3D),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
        elevation: 8,
      )
    );
  }
}
