import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../auth/domain/entities/user.dart';
import '../../../core/network/api_endpoints.dart';
import '../../soil_analysis/presentation/widgets/action_button.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _telephoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    _nomController = TextEditingController(text: user?.nom ?? '');
    _prenomController = TextEditingController(text: user?.prenom ?? '');
    _telephoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Get JWT token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expirée. Veuillez vous reconnecter.'),
          ),
        );
        return;
      }

      // Get current user data to find the user ID
      final getCurrentUserUseCase = ref.read(getCurrentUserProvider);
      final currentUserData = await getCurrentUserUseCase();

      if (currentUserData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de récupérer les données utilisateur. Veuillez vous reconnecter.'),
          ),
        );
        return;
      }

      // Extract user ID from current user data - try different paths
      int? userId;
      final user = ref.read(userProvider);

      // First try to get from SharedPreferences
      userId = prefs.getInt('user_id');

      // If not found, try to get from current user data
      if (userId == null) {
        // Try to get user ID from /auth/me response
        final authMeResponse = await http.get(
          Uri.parse(ApiEndpoints.buildUrl('/auth/me')),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (authMeResponse.statusCode == 200) {
          final authMeData = jsonDecode(authMeResponse.body);
          final userData = authMeData['user'] ?? authMeData['data'] ?? authMeData;

          if (userData != null && userData['id'] != null) {
            userId = userData['id'];
            // Store the user ID for future use
            await prefs.setInt('user_id', userId!);
          }
        }
      }

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID utilisateur non trouvé. Veuillez vous reconnecter.'),
          ),
        );
        return;
      }

      final response = await http.put(
        Uri.parse(ApiEndpoints.buildUrl('/users/farmers/$userId/profile')),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'lastname': _nomController.text.trim(),
          'firstname': _prenomController.text.trim(),
          'phone_number': _telephoneController.text.trim(),
          'calling_code': '+226', // Default for now, can be updated if needed
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true || data['message'] != null) {
          // Update the user provider with new data
          final userData = data['user'] ?? data['data'];
          final updatedUser = User(
            nom: userData?['lastname'] ?? userData?['nom'] ?? _nomController.text.trim(),
            prenom: userData?['firstname'] ?? userData?['prenom'] ?? _prenomController.text.trim(),
            phone: userData?['phone_number'] ?? userData?['telephone'] ?? _telephoneController.text.trim(),
            callingCode: userData?['calling_code'] ?? '+226',
            password: '', // Keep existing password or empty for security
          );
          ref.read(userProvider.notifier).state = updatedUser;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil mis à jour avec succès')),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Erreur lors de la mise à jour'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erreur serveur')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
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
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: const Text(
          'Modifier mes informations',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  hintText: 'Nom',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _prenomController,
                decoration: InputDecoration(
                  hintText: 'Prénom',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le prénom est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              IntlPhoneField(
                controller: _telephoneController,
                decoration: InputDecoration(
                  hintText: 'Téléphone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
                initialCountryCode: 'BF', // Burkina Faso
                onChanged: (phone) {
                  // Update the controller with the complete number
                  setState(() {
                    _telephoneController.text = phone.completeNumber;
                  });
                },
                validator: (value) {
                  if (value == null || value.number.isEmpty) {
                    return 'Le numéro de téléphone est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ActionButton(
                text: _isLoading ? 'Enregistrement...' : 'Enregistrer',
                onPressed: _isLoading ? null : _updateProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
