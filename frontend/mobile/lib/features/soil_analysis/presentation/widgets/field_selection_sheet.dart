import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/champ.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/parcelle.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/presentation/providers/champ_parcelle_provider.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/presentation/widgets/action_button.dart';

class FieldSelectionSheet extends ConsumerWidget {
  final void Function(Champ?) onFieldSelected;
  final void Function(Parcelle?) onParcelleSelected;
  final Champ? selectedField;
  final Parcelle? selectedParcelle;

  const FieldSelectionSheet({
    super.key,
    required this.onFieldSelected,
    required this.onParcelleSelected,
    this.selectedField,
    this.selectedParcelle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fieldsAsync = ref.watch(champsProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poignée de tirage
            Center(
              child: Container(
                width: 100,
                height: 8,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            
            // Titre
            const Text(
              'Sélectionner un champ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Liste des champs
            Expanded(
              child: fieldsAsync.when(
                data: (fields) {
                  if (fields.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.agriculture_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun champ enregistré',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Créez votre premier champ pour commencer',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: fields.length,
                    itemBuilder: (context, index) {
                      final champ = fields[index];
                      final isSelected = selectedField?.id == champ.id;
                      
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: isSelected ? Colors.green[50] : null,
                        child: ListTile(
                          title: Text(
                            champ.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(champ.location),
                          trailing: isSelected 
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          onTap: () {
                            onFieldSelected(champ);
                            onParcelleSelected(null);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Erreur: $error'),
                ),
              ),
            ),
            
            // Bouton pour créer un nouveau champ
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: ActionButton(
                text: 'Créer un nouveau champ',
                onPressed: () {
                  Navigator.pop(context);
                  _showCreateFieldDialog(context, ref);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showCreateFieldDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau champ'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du champ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Localisation',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Région, ville, etc.',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une localisation';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          Consumer(
            builder: (context, ref, _) {
              return ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      final newField = await ref.read(
                        createChampProvider({
                          'name': nameController.text,
                          'location': locationController.text,
                        }).future
                      );

                      if (newField != null && context.mounted) {
                        onFieldSelected(newField);
                        Navigator.pop(context);

                        // Afficher un message de succès
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Champ créé avec succès'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur lors de la création: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                child: const Text('Créer'),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ParcelleSelectionSheet extends ConsumerWidget {
  final String champId;
  final void Function(Parcelle) onParcelleSelected;
  final Parcelle? selectedParcelle;

  const ParcelleSelectionSheet({
    super.key,
    required this.champId,
    required this.onParcelleSelected,
    this.selectedParcelle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parcellesAsync = ref.watch(parcellesProvider(champId));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poignée de tirage
            Center(
              child: Container(
                width: 100,
                height: 8,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            
            // Titre
            const Text(
              'Sélectionner une parcelle',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Liste des parcelles
            Expanded(
              child: parcellesAsync.when(
                data: (parcelles) {
                  if (parcelles.isEmpty) {
                    return const Center(
                      child: Text('Aucune parcelle trouvée pour ce champ'),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: parcelles.length,
                    itemBuilder: (context, index) {
                      final parcelle = parcelles[index];
                      final isSelected = selectedParcelle?.id == parcelle.id;
                      
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: isSelected ? Colors.green[50] : null,
                        child: ListTile(
                          title: Text(
                            parcelle.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text('${parcelle.superficie} ha'),
                          trailing: isSelected 
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          onTap: () {
                            onParcelleSelected(parcelle);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Erreur: $error'),
                ),
              ),
            ),
            
            // Bouton pour créer une nouvelle parcelle
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: ActionButton(
                text: 'Créer une nouvelle parcelle',
                onPressed: () {
                  if (context.mounted) {
                    Navigator.pop(context);
                    _showCreateParcelleDialog(context, ref, champId);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showCreateParcelleDialog(BuildContext context, WidgetRef ref, String champId) {
    final nameController = TextEditingController();
    final superficieController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle parcelle'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la parcelle',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: superficieController,
                decoration: const InputDecoration(
                  labelText: 'Superficie (ha)',
                  border: OutlineInputBorder(),
                  suffixText: 'ha',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une superficie';
                  }
                  final superficie = double.tryParse(value);
                  if (superficie == null || superficie <= 0) {
                    return 'Veuillez entrer une superficie valide';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          Consumer(
            builder: (context, ref, _) {
              return ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      final newParcelle = await ref.read(
                        createParcelleProvider({
                          'champId': champId,
                          'name': nameController.text,
                          'superficie': double.parse(superficieController.text),
                        }).future
                      );

                      if (newParcelle != null && context.mounted) {
                        Navigator.pop(context);
                        onParcelleSelected(newParcelle);

                        // Afficher un message de succès
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Parcelle créée avec succès'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur lors de la création: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                child: const Text('Créer'),
              );
            },
          ),
        ],
      ),
    );
  }
}
