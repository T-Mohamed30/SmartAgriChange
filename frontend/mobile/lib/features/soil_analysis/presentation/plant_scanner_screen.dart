import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlantScannerScreen extends ConsumerStatefulWidget {
  const PlantScannerScreen({super.key});

  @override
  ConsumerState<PlantScannerScreen> createState() => _PlantScannerScreenState();
}

class _PlantScannerScreenState extends ConsumerState<PlantScannerScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0], // Use the first available camera
          ResolutionPreset.high,
        );

        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur d\'initialisation de la caméra: $e')),
        );
      }
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isTakingPicture) {
      return;
    }

    setState(() {
      _isTakingPicture = true;
    });

    try {
      final XFile image = await _controller!.takePicture();

      if (mounted) {
        // Navigate to analysis screen with the captured image
        Navigator.pushReplacementNamed(
          context,
          '/soil_analysis/analysis',
          arguments: {'imagePath': image.path},
        );
      }
    } catch (e) {
      print('Error taking picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la prise de photo: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          _isInitialized && _controller != null && _controller!.value.isInitialized
              ? CameraPreview(_controller!)
              : const Center(
                  child: CircularProgressIndicator(),
                ),

          // Top back button
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Bottom control bar
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Gallery button
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 28,
                    child: IconButton(
                      icon: const Icon(Icons.photo_library, color: Colors.white, size: 28),
                      onPressed: () {
                        // TODO: Implement gallery picker
                      },
                    ),
                  ),

                  // Capture button
                  GestureDetector(
                    onTap: _isTakingPicture ? null : _takePicture,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Center(
                        child: _isTakingPicture
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                                size: 32,
                              ),
                      ),
                    ),
                  ),

                  // Help button
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 28,
                    child: IconButton(
                      icon: const Icon(Icons.help_outline, color: Colors.white, size: 28),
                      onPressed: () {
                        // TODO: Implement help action
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
