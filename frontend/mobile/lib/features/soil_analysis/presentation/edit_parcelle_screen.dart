import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/domain/entities/parcelle.dart';
import 'package:smartagrichange_mobile/features/soil_analysis/presentation/providers/champ_parcelle_provider.dart';
import 'widgets/action_button.dart';

class EditParcelleBottomSheet extends ConsumerStatefulWidget {
  final Parcelle parcelle;

  const EditParcelleBottomSheet({super.key, required this.parcelle});

  @override
  ConsumerState<EditParcelleBottomSheet> createState() => _EditParcelleBottomSheetState();
}

class _EditParcelleBottomSheetState extends ConsumerState<EditParcelleBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _superficieController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.parcelle.name);
    _superficieController = TextEditingController(text: widget.parcelle.superficie.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _superficieController.dispose();
    super.dispose();
  }

  void _updateParcelle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final superficie = double.tryParse(_superficieController.text.trim());
      if (superficie == null) {
        throw Exception('Superficie invalide');
      }

      await ref.read(updateParcelleProvider({
        'id': widget.parcelle.id,
        'name': _nameController.text.trim(),
        'superficie': superficie,
        'champId': widget.parcelle.champId,
      }).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parcelle modifiée avec succès')),
        );
        Navigator.of(context).pop(true); // Retourner true pour indiquer le succès
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la modification: $e')),
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
              const Text('Modifier la parcelle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration('Nom de la parcelle'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Le nom de la parcelle est requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _superficieController,
                          decoration: _inputDecoration('Superficie (ha)'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La superficie est requise';
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
                ),
              ),
              const SizedBox(height: 20),
              ActionButton(
                text: _isLoading ? 'Modification...' : 'Modifier la parcelle',
                onPressed: _isLoading ? null : _updateParcelle,
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
