import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get user from auth provider
    final user = ref.watch(userProvider);

    final String fullName = user != null
        ? '${user.nom} ${user.prenom}'
        : 'Utilisateur';
    final String phoneNumber = user != null
        ? '(${user.callingCode}) ${user.phone}'
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // Removed appBar as requested
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User info row
            Row(
              children: [
                Image.asset(
                  'assets/icons/profile.png',
                  width: 64,
                  height: 64,
                  color: Colors.black, // icons rendered in black
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phoneNumber,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Subscription card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF007F3D),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Votre abonnement actuel',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Standard',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Expire le 21 aout 2026',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Options card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Compte section
                  _buildSectionTitle('Compte'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildListTile(
                      icon: ImageIcon(
                        AssetImage(
                          'assets/icons/interface-user-single--close-geometric-human-person-single-up-user--Streamline-Core.png',
                        ),
                        color: Colors.black,
                      ),
                      text: 'Modifié mes informations',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildListTile(
                      icon: const Icon(Icons.lock_outline, color: Colors.black),
                      text: 'Changer mon mot de passe',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildListTile(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      text: 'Se déconnecter',
                      onTap: () async {
                        // Show confirmation dialog
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Déconnexion'),
                            content: const Text(
                              'Êtes-vous sûr de vouloir vous déconnecter ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Se déconnecter'),
                              ),
                            ],
                          ),
                        );

                        if (shouldLogout == true) {
                          // Clear all stored authentication data
                          final prefs = await SharedPreferences.getInstance();
                          await prefs
                              .clear(); // Clear all preferences to be safe

                          // Clear user provider state
                          ref.read(userProvider.notifier).state = null;

                          // Navigate to welcome screen and clear navigation stack
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/welcome',
                              (route) => false,
                            );
                          }
                        }
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1),
                  ),
                  // Abonnement section
                  _buildSectionTitle('Abonnement'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildListTile(
                      icon: ImageIcon(
                        AssetImage('assets/icons/reload.png'),
                        color: Colors.black,
                      ),
                      text: 'Renouveler',
                      onTap: () {
                        // TODO: Implement renewal action
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1),
                  ),
                  // Politique section
                  _buildSectionTitle('Politique'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildListTile(
                      icon: ImageIcon(
                        AssetImage('assets/icons/doc.png'),
                        color: Colors.black,
                      ),
                      text: 'Conditions d\'utilisation',
                      onTap: () {
                        // TODO: Implement navigation to terms
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildListTile(
                      icon: ImageIcon(
                        AssetImage('assets/icons/confidence.png'),
                        color: Colors.black,
                      ),
                      text: 'Politique de confidentialité',
                      onTap: () {
                        // TODO: Implement navigation to privacy policy
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildListTile(
                      icon: ImageIcon(
                        AssetImage(
                          'assets/icons/image-picture-landscape-1--photos-photo-landscape-picture-photography-camera-pictures--Streamline-Core.png',
                        ),
                        color: Colors.black,
                      ),
                      text: 'Version de l’application',
                      trailing: const Text(
                        '1.00',
                        style: TextStyle(color: Colors.black54),
                      ),
                      onTap: null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildListTile({
    required Widget icon,
    required String text,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: icon,
      title: Text(text),
      trailing: trailing ?? const Icon(Icons.keyboard_arrow_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      horizontalTitleGap: 0,
      minVerticalPadding: 0,
      dense: true,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Consumer(
      builder: (context, ref, child) {
        return BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: 3, // Account tab is selected
          onTap: (index) {
            // Handle navigation
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/home');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/champs');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/historique');
                break;
              case 3:
                // Already on account page
                break;
            }
          },
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
}
