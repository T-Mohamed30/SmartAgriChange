import 'dart:typed_data';
import 'package:flutter/material.dart';

class ScanAnimationOverlay extends StatefulWidget {
  final Uint8List imageBytes;
  final VoidCallback onClose;

  const ScanAnimationOverlay({
    Key? key,
    required this.imageBytes,
    required this.onClose,
  }) : super(key: key);

  @override
  _ScanAnimationOverlayState createState() => _ScanAnimationOverlayState();
}

class _ScanAnimationOverlayState extends State<ScanAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // vitesse du scan
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF2E1A47),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E1A47),
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: widget.onClose,
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Image parfaitement centrée
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                widget.imageBytes,
                fit: BoxFit.cover,
                width: 300,
                height: 400,
              ),
            ),
          ),

          // Barre animée pleine largeur
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double barHeight = _controller.value * screenHeight;

              return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: screenWidth, // toute la largeur
                  height: barHeight,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0x00E5F8EC), // transparent
                        Color(0xB0007F3D), // sommet vert semi-opaque
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
