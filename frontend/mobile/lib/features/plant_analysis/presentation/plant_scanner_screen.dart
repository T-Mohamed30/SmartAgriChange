import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
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
  final ImagePicker _imagePicker = ImagePicker();

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
    debugPrint('PlantScannerScreen: Initializing service...');
    try {
      final dioClient = Provider.of<DioClient>(context, listen: false);
      _plantAnalysisService = PlantAnalysisService(dioClient);
      debugPrint('PlantScannerScreen: Service initialized successfully');
    } catch (e) {
      debugPrint('PlantScannerScreen: Error initializing service: $e');
      setState(() {
        _errorMessage = 'Erreur d\'initialisation du service: $e';
      });
    }
  }

  Future<void> _initCamera() async {
    debugPrint('PlantScannerScreen: Initializing camera...');
    try {
      cameras = await availableCameras();
      debugPrint(
        'PlantScannerScreen: Available cameras: ${cameras?.length ?? 0}',
      );
      if (cameras != null && cameras!.isNotEmpty) {
        debugPrint('PlantScannerScreen: Using camera: ${cameras!.first.name}');
        _controller = CameraController(
          cameras!.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        debugPrint('PlantScannerScreen: Camera initialized successfully');
        if (mounted) setState(() {});
      } else {
        debugPrint('PlantScannerScreen: No cameras available');
        setState(() {
          _errorMessage = 'Aucune caméra disponible';
        });
      }
    } catch (e) {
      // Handle camera initialization error
      debugPrint('PlantScannerScreen: Error initializing camera: $e');
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
    debugPrint('PlantScannerScreen: Capture button pressed');
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing ||
        _isAnalyzing) {
      debugPrint(
        'PlantScannerScreen: Cannot capture - controller: $_controller, initialized: ${_controller?.value.isInitialized}, capturing: $_isCapturing, analyzing: $_isAnalyzing',
      );
      return;
    }

    setState(() {
      _isCapturing = true;
      _errorMessage = null;
    });

    try {
      debugPrint('PlantScannerScreen: Taking picture...');
      final image = await _controller!.takePicture();
      debugPrint('PlantScannerScreen: Picture taken at: ${image.path}');
      final bytes = await image.readAsBytes();
      debugPrint('PlantScannerScreen: Image bytes length: ${bytes.length}');
      setState(() {
        _capturedImageBytes = bytes;
      });

      // Start analysis
      await _analyzeImage(XFile(image.path));
    } catch (e) {
      debugPrint('PlantScannerScreen: Error during capture: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors de la capture: $e')));
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _onGalleryPressed() async {
    debugPrint('PlantScannerScreen: Gallery button pressed');
    if (_isCapturing || _isAnalyzing) {
      debugPrint(
        'PlantScannerScreen: Cannot select from gallery - capturing: $_isCapturing, analyzing: $_isAnalyzing',
      );
      return;
    }

    try {
      debugPrint('PlantScannerScreen: Picking image from gallery...');
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        debugPrint('PlantScannerScreen: Image selected: ${pickedFile.path}');
        final bytes = await pickedFile.readAsBytes();
        debugPrint(
          'PlantScannerScreen: Gallery image bytes length: ${bytes.length}',
        );
        setState(() {
          _capturedImageBytes = bytes;
          _isCapturing = true;
        });

        // Start analysis
        await _analyzeImage(pickedFile);
      } else {
        debugPrint('PlantScannerScreen: No image selected from gallery');
      }
    } catch (e) {
      debugPrint('PlantScannerScreen: Error selecting from gallery: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection: $e')),
      );
    }
  }

  Future<void> _analyzeImage(XFile imageFile) async {
    debugPrint('PlantScannerScreen: Starting image analysis...');
    if (_plantAnalysisService == null) {
      debugPrint('PlantScannerScreen: PlantAnalysisService is null');
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      debugPrint('PlantScannerScreen: Showing loading dialog...');
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

      debugPrint(
        'PlantScannerScreen: Calling API to analyze image: ${imageFile.path}',
      );
      // Call API to analyze the image
      final analysisResult = await _plantAnalysisService!.analyzePlantImage(
        imageFile,
      );
      debugPrint('PlantScannerScreen: Analysis completed successfully');

      Navigator.of(context).pop(); // Remove loading dialog

      // Check if anomaly is detected based on prediction format: PlantName___healthy or PlantName___AnomalyName
      final prediction = analysisResult.modelResult.prediction;
      final hasAnomaly =
          prediction.contains('___') && !prediction.contains('___healthy');

      // Navigate to appropriate detail page
      if (mounted) {
        debugPrint('PlantScannerScreen: Navigating to detail page...');
        final routeName = hasAnomaly
            ? '/plant_analysis/detail'
            : '/plant_analysis/healthy_detail';
        Navigator.of(context).pushReplacementNamed(
          routeName,
          arguments: {
            'analysisResult': analysisResult,
            'imageBytes': _capturedImageBytes,
            'showHealthyMessage': !hasAnomaly,
          },
        );
      }
    } catch (e) {
      debugPrint('PlantScannerScreen: Error during analysis: $e');
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
                        onTap: _onGalleryPressed,
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
