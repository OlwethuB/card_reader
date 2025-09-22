import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CardScanner extends StatefulWidget {
  final Function(String, String) onCardScanned;

  const CardScanner({super.key, required this.onCardScanned});

  @override
  State<CardScanner> createState() => _CardScannerState();
}

class _CardScannerState extends State<CardScanner> {
  CameraController? _controller;
  late List<CameraDescription> _cameras;
  bool _isInitialized = false;
  bool _isScanning = false;
  String _scannedText = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.medium);
    await _controller!.initialize();
    setState(() => _isInitialized = true);
    _startScanning();
  }

  void _startScanning() {
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_isScanning || !mounted) return;

      _isScanning = true;
      try {
        final image = await _controller!.takePicture();
        final File imageFile = File(image.path);
        await _processImage(imageFile);
      } catch (e) {
        debugPrint("Error taking picture: $e");
      }
      _isScanning = false;
    });
  }

  Future<void> _processImage(File imageFile) async {
    final textRecognizer = TextRecognizer();
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    String fullText = recognizedText.text;
    setState(() => _scannedText = fullText);

    // Extract card number
    final cardNumber = _extractCardNumber(fullText);
    if (cardNumber.isNotEmpty) {
      widget.onCardScanned(cardNumber, fullText);
    }

    textRecognizer.close();
  }

  String _extractCardNumber(String text) {
    // Remove all non-digit characters
    String cleaned = text.replaceAll(RegExp(r'\D'), '');
    
    // Look for sequences of 13-19 digits (valid card number lengths)
    RegExp cardPattern = RegExp(r'\b\d{13,19}\b');
    Match? match = cardPattern.firstMatch(cleaned);
    
    return match?.group(0) ?? '';
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        CameraPreview(_controller!),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black54,
            padding: const EdgeInsets.all(8),
            child: Text(
              _scannedText.isNotEmpty 
                ? 'Detected: $_scannedText' 
                : 'Position card in frame...',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}