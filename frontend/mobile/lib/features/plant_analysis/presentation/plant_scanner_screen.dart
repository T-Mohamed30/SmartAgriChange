import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
        _isCapturing) {
      return;
    }

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

        // Analysis is not mandatory linked to a parcelle, so pass null
        final int? parcelleId = null;

        if (kIsWeb) {
          // On web, convert image bytes to base64 string
          final base64Image = base64Encode(bytes);
          AnalysePlante analyse = await PlantAnalysisApi.analyserPlanteAuto(
            parcelleId,
            base64Image,
            token,
          );
          Navigator.of(context).pop(); // remove loading
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(
              '/plant_analysis/detail',
              arguments: {'analysisId': analyse.id},
            );
          }
          return;
        } else {
          // On mobile/native, use File
          final file = File(image.path);
          AnalysePlante analyse = await PlantAnalysisApi.analyserPlanteAuto(
            parcelleId,
            file,
            token,
          );
          Navigator.of(context).pop(); // remove loading
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(
              '/plant_analysis/detail',
              arguments: {'analysisId': analyse.id},
            );
          }
          return;
        }
      } catch (e) {
        Navigator.of(context).pop();
        // Show error and allow retry
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'analyse: $e. Veuillez réessayer.')),
        );
        setState(() {
          _isCapturing = false;
          _capturedImageBytes = null;
        });
        return;
      }
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
