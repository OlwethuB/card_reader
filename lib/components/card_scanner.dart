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
  String _lastCardNumber = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      _controller = CameraController(_cameras[0], ResolutionPreset.high);
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
      _startScanning();
    } catch (e) {
      debugPrint("Camera initialization error: $e");
    }
  }

  void _startScanning() {
    Timer.periodic(const Duration(seconds: 3), (timer) async {
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
    try {
      final textRecognizer = TextRecognizer();
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      String fullText = recognizedText.text;
      String cardNumber = _extractCardNumber(fullText);
      
      if (mounted) {
        setState(() {
          _scannedText = fullText;
        });
      }

      // Only trigger callback if we found a new card number
      if (cardNumber.isNotEmpty && cardNumber != _lastCardNumber) {
        _lastCardNumber = cardNumber;
        widget.onCardScanned(cardNumber, fullText);
      }

      textRecognizer.close();
    } catch (e) {
      debugPrint("Error processing image: $e");
    }
  }

  String _extractCardNumber(String text) {
    // Improved card number extraction
    String cleaned = text.replaceAll(RegExp(r'\s+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\D'), '');
    
    // Look for valid card number sequences
    RegExp cardPattern = RegExp(r'\b\d{13,19}\b');
    Match? match = cardPattern.firstMatch(cleaned);
    
    String potentialNumber = match?.group(0) ?? '';
    
    // Basic Luhn check for better accuracy
    if (potentialNumber.isNotEmpty && _isValidLuhn(potentialNumber)) {
      return potentialNumber;
    }
    
    return '';
  }

  bool _isValidLuhn(String number) {
    int sum = 0;
    bool alternate = false;
    
    for (int i = number.length - 1; i >= 0; i--) {
      int digit = int.parse(number[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return (sum % 10) == 0;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Initializing camera...'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initializeCamera,
                child: const Text('Retry Camera'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller!),
          
          // Camera overlay with guide
          Positioned(
            top: 100,
            left: 50,
            right: 50,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card, size: 50, color: Colors.white.withOpacity(0.7)),
                  const SizedBox(height: 10),
                  Text(
                    'Position card in frame',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          
          // Status display
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  if (_scannedText.isNotEmpty) ...[
                    const Text(
                      'Detected Text:',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _scannedText.length > 100 
                          ? '${_scannedText.substring(0, 100)}...' 
                          : _scannedText,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    const Text(
                      'Scanning... Ensure good lighting and clear text',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (_isScanning) ...[
                    const SizedBox(height: 8),
                    const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}