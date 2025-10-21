import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/champ.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/presentation/providers/champ_parcelle_provider.dart';
import 'widgets/action_button.dart';

class EditChampBottomSheet extends ConsumerStatefulWidget {
  final Champ champ;

  const EditChampBottomSheet({super.key, required this.champ});

  @override
  ConsumerState<EditChampBottomSheet> createState() => _EditChampBottomSheetState();
}

class _EditChampBottomSheetState extends ConsumerState<EditChampBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.champ.name);
    _locationController = TextEditingController(text: widget.champ.location);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _updateChamp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    debugPrint('EditChamp: Starting champ update for ID: ${widget.champ.id}');

    try {
      await ref.read(updateChampProvider({
        'id': widget.champ.id,
        'name': _nameController.text.trim(),
        'location': _locationController.text.trim(),
      }).future);

      debugPrint('EditChamp: Champ update successful for ID: ${widget.champ.id}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Champ modifié avec succès')),
        );
        Navigator.of(context).pop(true); // Retourner true pour indiquer le succès
      }
    } catch (e) {
      debugPrint('EditChamp: Error updating champ ID ${widget.champ.id}: $e');

      if (mounted) {
        // Check if the error is due to unauthorized access
        String errorMessage = 'Erreur lors de la modification: $e';
        if (e.toString().contains('Unauthorized') || e.toString().contains('failed')) {
          errorMessage = 'Accès non autorisé. Veuillez vous reconnecter.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: bottomInset > 0 ? bottomInset + 16 : 24),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 100, height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Modifier le champ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration('Nom du champ'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Le nom du champ est requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _locationController,
                          decoration: _inputDecoration('Localisation'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La localisation est requise';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ActionButton(
                text: _isLoading ? 'Modification...' : 'Modifier le champ',
                onPressed: _isLoading ? null : _updateChamp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF007F3D)),
    ),
  );
}
