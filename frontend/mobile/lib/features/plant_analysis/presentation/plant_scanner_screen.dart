import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/plant_analysis_api.dart';
import '../models/plant_analysis_models.dart';

import 'scan_animation_overlay.dart';

class PlantScannerScreen extends StatefulWidget {
  const PlantScannerScreen({super.key});

  @override
  _PlantScannerScreenState createState() => _PlantScannerScreenState();
}

class _PlantScannerScreenState extends State<PlantScannerScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;

  bool _isCapturing = false;
  Uint8List? _capturedImageBytes;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _controller = CameraController(
          cameras!.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) setState(() {});
      }
    } catch (e) {
      // Handle camera initialization error
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onCapturePressed() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing)
      return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final image = await _controller!.takePicture();
      final bytes = await image.readAsBytes();
      setState(() {
        _capturedImageBytes = bytes;
      });

      // After capture, upload to backend and get analysis
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('jwt_token') ?? '';

        // Use parcelle 1 as example; adapt to real selected parcelle
        final parcelleId = 1;

        final file = File(image.path);
        AnalysePlante analyse = await PlantAnalysisApi.analyserPlanteMultipart(
          parcelleId,
          file,
          token,
        );

        Navigator.of(context).pop(); // remove loading

        // Navigate to detail page using the created analysis ID
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            '/plant_analysis/detail',
            arguments: {'analysisId': analyse.id},
          );
        }
        return;
      } catch (e) {
        Navigator.of(context).pop();
        // proceed to navigate to detail page with local image as fallback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload échoué, affichage local: $e')),
        );
      }

      // Keep _isCapturing true to switch UI to scan animation state
      // The UI will show the scan animation screen with the captured photo

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image capturée: \${image.path}')));

      // After 5 seconds, navigate to the plant detail page
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            '/plant_analysis/detail',
            arguments: {
              'imagePath': image.path,
              // Add other necessary arguments here
            },
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors de la capture: \$e')));
      setState(() {
        _isCapturing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Black background for camera area
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview or placeholder
            Center(
              child: _controller != null && _controller!.value.isInitialized
                  ? SizedBox.expand(
                      child: Stack(
                        children: [
                          CameraPreview(_controller!),
                          if (_isCapturing && _capturedImageBytes != null)
                            Positioned.fill(
                              child: ScanAnimationOverlay(
                                imageBytes: _capturedImageBytes!,
                                onClose: () {
                                  setState(() {
                                    _isCapturing = false;
                                    _capturedImageBytes = null;
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),

            // Back button top-left in purple area
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                color: const Color(0xFF2E1A47),
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.only(left: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isCapturing ? Icons.close : Icons.arrow_back,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      if (_isCapturing) {
                        setState(() {
                          _isCapturing = false;
                          _capturedImageBytes = null;
                        });
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              ),
            ),

            // Bottom controls in purple area
            if (!_isCapturing)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 192,
                  color: const Color(0xFF2E1A47),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Gallery icon button
                      GestureDetector(
                        onTap: () {
                          // TODO: Open gallery picker
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ouvrir la galerie')),
                          );
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.photo_library,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),

                      // Capture button
                      GestureDetector(
                        onTap: _onCapturePressed,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                      // Help icon button
                      GestureDetector(
                        onTap: () {
                          // TODO: Show help dialog or info
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Aide à la capture')),
                          );
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.help_outline,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
