import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartagrichange_mobile/core/network/dio_client.dart';
import 'package:smartagrichange_mobile/features/plant_analysis/models/anomaly_analysis_models.dart';
import 'package:smartagrichange_mobile/features/plant_analysis/services/plant_analysis_service.dart';

import 'scan_animation_overlay.dart';

class PlantScannerScreen extends StatefulWidget {
  const PlantScannerScreen({super.key});

  @override
  _PlantScannerScreenState createState() => _PlantScannerScreenState();
}

class _PlantScannerScreenState extends State<PlantScannerScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  PlantAnalysisService? _plantAnalysisService;

  bool _isCapturing = false;
  bool _isAnalyzing = false;
  Uint8List? _capturedImageBytes;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initService();
  }

  void _initService() {
    final dioClient = Provider.of<DioClient>(context, listen: false);
    _plantAnalysisService = PlantAnalysisService(dioClient);
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
      setState(() {
        _errorMessage = 'Erreur d\'initialisation de la caméra: $e';
      });
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
        _isCapturing ||
        _isAnalyzing)
      return;

    setState(() {
      _isCapturing = true;
      _errorMessage = null;
    });

    try {
      final image = await _controller!.takePicture();
      final bytes = await image.readAsBytes();
      setState(() {
        _capturedImageBytes = bytes;
      });

      // Start analysis
      await _analyzeImage(File(image.path));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors de la capture: $e')));
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    if (_plantAnalysisService == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Analyse de l\'image en cours...'),
            ],
          ),
        ),
      );

      // Call API to analyze the image
      final analysisResult = await _plantAnalysisService!.analyzePlantImage(
        imageFile,
      );

      Navigator.of(context).pop(); // Remove loading dialog

      // Navigate to detail page with analysis result
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/plant_analysis/detail',
          arguments: {
            'analysisResult': analysisResult,
            'imageBytes': _capturedImageBytes,
          },
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Remove loading dialog

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors de l\'analyse: $e')));

      setState(() {
        _isAnalyzing = false;
        _isCapturing = false;
        _capturedImageBytes = null;
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
                                    _isAnalyzing = false;
                                    _capturedImageBytes = null;
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    )
                  : Center(
                      child: _errorMessage != null
                          ? Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            )
                          : const CircularProgressIndicator(),
                    ),
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
                          _isAnalyzing = false;
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
            if (!_isCapturing && !_isAnalyzing)
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
                          child: const Center(
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                              size: 32,
                            ),
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

            // Loading overlay during analysis
            if (_isAnalyzing)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Analyse en cours...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
