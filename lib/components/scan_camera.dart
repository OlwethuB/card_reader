import 'dart:io';
import 'package:card_reader/components/card_preview.dart';
import 'package:card_reader/components/card_scanner.dart';
import 'package:card_reader/utils/card_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class ScanCamera extends StatefulWidget {
  final Function(Map<String, dynamic>)? onCardScanned;
  
  const ScanCamera({super.key, this.onCardScanned});

  @override
  State<ScanCamera> createState() => _ScanCameraState();
}

class _ScanCameraState extends State<ScanCamera> {
  File? _imageFile;
  String? _scannedCardNumber;
  String? _scannedCardType;
  final ImagePicker _picker = ImagePicker();
  bool _showScanner = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 600,
      );

      if (pickedFile != null) {
        await _processImage(File(pickedFile.path));
      }
    } catch (e) {
      debugPrint("Image pick error: $e");
    }
  }

  Future<void> _processImage(File imageFile) async {
    try {
      final textRecognizer = TextRecognizer();
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      String fullText = recognizedText.text;
      String cardNumber = _extractCardNumber(fullText);
      
      if (cardNumber.isNotEmpty) {
        setState(() {
          _imageFile = imageFile;
          _scannedCardNumber = cardNumber;
          _scannedCardType = getCardType(cardNumber);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No card number detected in image')),
          );
        }
      }

      textRecognizer.close();
    } catch (e) {
      debugPrint("Error processing image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error processing image')),
        );
      }
    }
  }

  String _extractCardNumber(String text) {
    String cleaned = text.replaceAll(RegExp(r'\D'), '');
    RegExp cardPattern = RegExp(r'\b\d{13,19}\b');
    Match? match = cardPattern.firstMatch(cleaned);
    return match?.group(0) ?? '';
  }

  void _handleCardScanned(String cardNumber, String fullText) {
    setState(() {
      _scannedCardNumber = cardNumber;
      _scannedCardType = getCardType(cardNumber);
      _showScanner = false;
    });
  }

  void _resetScan() {
    setState(() {
      _scannedCardNumber = null;
      _scannedCardType = null;
      _imageFile = null;
    });
  }

  void _handleSave(String country, String cvv) {
    if (widget.onCardScanned != null) {
      widget.onCardScanned!({
        'cardNumber': _scannedCardNumber,
        'cardType': _scannedCardType,
        'country': country,
        'cvv': cvv,
      });
    }
    
    // Reset after saving
    _resetScan();
  }

  @override
  Widget build(BuildContext context) {
    if (_showScanner) {
      return CardScanner(onCardScanned: _handleCardScanned);
    }

    if (_scannedCardNumber != null) {
      return CardPreview(
        cardNumber: _scannedCardNumber!,
        cardType: _scannedCardType!,
        onSave: _handleSave,
        onRescan: _resetScan,
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Scan credit card using camera or select from gallery',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          _imageFile != null
              ? Image.file(
                  _imageFile!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                )
              : const Icon(Icons.credit_card, size: 100, color: Colors.grey),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Scan with Camera'),
            onPressed: () => setState(() => _showScanner = true),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text('Select from Gallery'),
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}