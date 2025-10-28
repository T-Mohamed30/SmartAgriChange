import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/champ.dart';
import 'providers/champ_parcelle_provider.dart';
import 'detection_capteurs.dart';
import 'edit_champ_screen.dart';
import 'edit_parcelle_screen.dart';

// Swipeable Card Widget with Edit and Delete Actions
class SwipeableCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String itemName;
  final String itemType; // 'champ' or 'parcelle'
  final String itemId;

  const SwipeableCard({
    super.key,
    required this.child,
    required this.onEdit,
    required this.onDelete,
    required this.itemName,
    required this.itemType,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('${itemType}_$itemId'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(
              'Supprimer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Colors.blue.shade400,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(
              'Modifier',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Delete action
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Supprimer ${itemType == 'champ' ? 'le champ' : 'la parcelle'}',
                ),
                content: Text(
                  'Êtes-vous sûr de vouloir supprimer "$itemName" ?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onDelete();
                    },
                    child: const Text(
                      'Supprimer',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            },
          );
        } else if (direction == DismissDirection.startToEnd) {
          // Edit action
          onEdit();
          return false; // Don't dismiss, just trigger edit
        }
        return false;
      },
      child: child,
    );
  }
}

// Long Press Card Widget with Zoom and Blur Effect
class LongPressCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String itemName;
  final String itemType; // 'champ' or 'parcelle'

  const LongPressCard({
    super.key,
    required this.child,
    required this.onEdit,
    required this.onDelete,
    required this.itemName,
    required this.itemType,
  });

  @override
  State<LongPressCard> createState() => _LongPressCardState();
}

class _LongPressCardState extends State<LongPressCard> {
  OverlayEntry? _overlayEntry;
  bool _isMenuVisible = false;

  void _showContextMenu(BuildContext context) {
    if (_isMenuVisible) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    // Calculate menu position to avoid overflow
    double menuLeft = position.dx + 20;
    double menuTop = position.dy + size.height + 10;

    // Adjust horizontal position if menu would overflow
    if (menuLeft + 180 > screenSize.width) {
      menuLeft = screenSize.width - 190; // 180 + 10 padding
    }

    // Adjust vertical position if menu would overflow
    if (menuTop + 100 > screenSize.height) {
      // Approximate menu height
      menuTop = position.dy - 110; // Show above the card
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Blur background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          // Tap to dismiss
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideContextMenu,
              behavior: HitTestBehavior.opaque,
            ),
          ),
          // Highlighted card with zoom effect
          Positioned(
            left: position.dx,
            top: position.dy,
            width: size.width,
            height: size.height,
            child: Transform.scale(
              scale: 1.05,
              child: Material(
                elevation: 0,
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
          // Context menu card
          Positioned(
            left: menuLeft,
            top: menuTop,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 220, // Increased width to prevent text wrapping
                height: 80, // Reduced height
                decoration: BoxDecoration(
                  color: Colors
                      .grey
                      .shade50, // Light gray background instead of pure white
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit option
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _hideContextMenu();
                          widget.onEdit();
                        },
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ), // Reduced vertical padding
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Modifier ${widget.itemType == 'champ' ? 'le champ' : 'la parcelle'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Divider
                    Container(height: 1, color: Colors.grey.withOpacity(0.2)),
                    // Delete option
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _hideContextMenu();
                          widget.onDelete();
                        },
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ), // Reduced vertical padding
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Supprimer ${widget.itemType == 'champ' ? 'le champ' : 'la parcelle'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isMenuVisible = true);
  }

  void _hideContextMenu() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    if (mounted) {
      setState(() => _isMenuVisible = false);
    }
  }

  @override
  void dispose() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showContextMenu(context),
      child: widget.child,
    );
  }
}

// Widget ChampCard pour affichage identique à SensorCard
class ChampCard extends StatelessWidget {
  final Champ champ;
  final VoidCallback? onTap;
  const ChampCard({required this.champ, this.onTap, super.key});

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
  const ParcelleCount({required this.champId, super.key});

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
  const ChampsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final champsAsync = ref.watch(champsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liste des champs',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
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
                          return LongPressCard(
                            itemName: champ.name,
                            itemType: 'champ',
                            onEdit: () async {
                              final result = await showModalBottomSheet<bool>(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) =>
                                    EditChampBottomSheet(champ: champ),
                              );
                              if (result == true) {
                                // Refresh the list
                                ref.invalidate(champsProvider);
                              }
                            },
                            onDelete: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Supprimer le champ'),
                                    content: Text(
                                      'Êtes-vous sûr de vouloir supprimer "${champ.name}" ?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          try {
                                            await ref.read(
                                              deleteChampProvider(
                                                champ.id,
                                              ).future,
                                            );
                                            ref.invalidate(champsProvider);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '${champ.name} supprimé',
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            debugPrint(
                                              'ChampsListPage: Error deleting champ ${champ.name} (ID: ${champ.id}): $e',
                                            );
                                            if (context.mounted) {
                                              // Check if the error is due to unauthorized access
                                              String errorMessage =
                                                  'Erreur lors de la suppression: $e';
                                              if (e.toString().contains(
                                                    'Unauthorized',
                                                  ) ||
                                                  e.toString().contains(
                                                    'failed',
                                                  )) {
                                                errorMessage =
                                                    'Accès non autorisé. Veuillez vous reconnecter.';
                                              }
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(errorMessage),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: const Text(
                                          'Supprimer',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: InkWell(
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
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class ParcellesListPage extends ConsumerWidget {
  final Champ champ;
  const ParcellesListPage({required this.champ, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parcellesAsync = ref.watch(parcellesProvider(champ.id));
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 12,
            top: 8,
            bottom: 8,
          ), // espace du bord gauche et vertical

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
        title: Text(
          champ.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
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
                      return LongPressCard(
                        itemName: parcelle.name,
                        itemType: 'parcelle',
                        onEdit: () async {
                          final result = await showModalBottomSheet<bool>(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) =>
                                EditParcelleBottomSheet(parcelle: parcelle),
                          );
                          if (result == true) {
                            // Refresh the list
                            ref.invalidate(parcellesProvider(champ.id));
                          }
                        },
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Supprimer la parcelle'),
                                content: Text(
                                  'Êtes-vous sûr de vouloir supprimer "${parcelle.name}" ?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      try {
                                        await ref.read(
                                          deleteParcelleProvider(
                                            parcelle.id,
                                          ).future,
                                        );
                                        ref.invalidate(
                                          parcellesProvider(champ.id),
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${parcelle.name} supprimé',
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        debugPrint(
                                          'ParcellesListPage: Error deleting parcelle ${parcelle.name} (ID: ${parcelle.id}): $e',
                                        );
                                        if (context.mounted) {
                                          // Check if the error is due to unauthorized access
                                          String errorMessage =
                                              'Erreur lors de la suppression: $e';
                                          if (e.toString().contains(
                                                'Unauthorized',
                                              ) ||
                                              e.toString().contains('failed')) {
                                            errorMessage =
                                                'Accès non autorisé. Veuillez vous reconnecter.';
                                          }
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(errorMessage),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text(
                                      'Supprimer',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
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
                        ),
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
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
