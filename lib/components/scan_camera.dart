import 'dart:io';
import 'package:card_reader/components/card_preview.dart';
import 'package:card_reader/utils/card_utils.dart';
import 'package:card_reader/utils/ocr_utils.dart';
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
  String? _fullScannedText;
  String? _scannedCVV;
  String? _scannedExpiryMonth;
  String? _scannedExpiryYear;
  String? _scannedCardHolder;
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isProcessing = true;
        _scannedCardNumber = null;
        _scannedCardType = null;
        _fullScannedText = null;
        _scannedCVV = null;
        _scannedExpiryMonth = null;
        _scannedExpiryYear = null;
        _scannedCardHolder = null;
      });

      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        await _processImage(File(pickedFile.path));
      }
    } catch (e) {
      debugPrint("Image pick error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error picking image')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _processImage(File imageFile) async {
    try {
      setState(() {
        _isProcessing = true;
      });

      final textRecognizer = TextRecognizer();
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      String fullText = recognizedText.text;

      // Use OcrUtils for all extractions (no duplication)
      String cardNumber = OcrUtils.extractCardNumber(fullText);
      String cvv = OcrUtils.extractCVV(fullText);
      Map<String, String> expiryDate = OcrUtils.extractExpiryDate(fullText);
      String cardHolder = OcrUtils.extractCardHolder(fullText);

      debugPrint("Full OCR Text: $fullText");
      debugPrint("Extracted Card Number: $cardNumber");
      debugPrint("Extracted CVV: $cvv");
      debugPrint("Extracted Expiry: $expiryDate");
      debugPrint("Extracted Card Holder: $cardHolder");

      if (mounted) {
        setState(() {
          _fullScannedText = fullText;
          _scannedCardNumber = cardNumber;
          _scannedCardType =
              cardNumber.isNotEmpty ? getCardType(cardNumber) : 'Unknown';
          _scannedCVV = cvv;
          _scannedExpiryMonth = expiryDate['month'];
          _scannedExpiryYear = expiryDate['year'];
          _scannedCardHolder = cardHolder;
          _isProcessing = false;
        });
      }

      if (cardNumber.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'No card number detected. Try a clearer image.',
            ),
            action: SnackBarAction(
              label: 'View OCR',
              onPressed: () => _showOcrResults(fullText),
            ),
          ),
        );
      }

      textRecognizer.close();
    } catch (e) {
      debugPrint("Error processing image: $e");
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error processing image')));
      }
    }
  }

  void _showOcrResults(String fullText) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Full OCR Results'),
            content: SingleChildScrollView(child: Text(fullText)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _resetScan() {
    setState(() {
      _scannedCardNumber = null;
      _scannedCardType = null;
      _imageFile = null;
      _fullScannedText = null;
      _scannedCVV = null;
      _scannedExpiryMonth = null;
      _scannedExpiryYear = null;
      _scannedCardHolder = null;
    });
  }

  void _handleSave(
    String country,
    String cvv,
    String expiryMonth,
    String expiryYear,
    String cardHolder,
  ) {
    if (_scannedCardNumber != null && widget.onCardScanned != null) {
      widget.onCardScanned!({
        'cardNumber': _scannedCardNumber!,
        'cardType': _scannedCardType!,
        'country': country,
        'cvv': cvv,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'cardHolder': cardHolder,
      });
    }

    _resetScan();
  }

  @override
  Widget build(BuildContext context) {
    if (_scannedCardNumber != null) {
      return CardPreview(
        cardNumber: _scannedCardNumber!,
        cardType: _scannedCardType!,
        cvv: _scannedCVV ?? '',
        expiryMonth: _scannedExpiryMonth ?? '',
        expiryYear: _scannedExpiryYear ?? '',
        cardHolder: _scannedCardHolder ?? '',
        onSave: _handleSave,
        onRescan: _resetScan,
      );
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                // 'Select a card to scan from the gallery',
                'Scan credit card using camera or select from gallery',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // selected image with OCR results
              if (_imageFile != null) ...[
                Card(
                  elevation: 4,
                  child: Column(
                    children: [
                      Image.file(
                        _imageFile!,
                        width: 300,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      if (_isProcessing)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 16),
                              Text('Processing image...'),
                            ],
                          ),
                        ),
                      if (_fullScannedText != null && !_isProcessing) ...[
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'OCR Results:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Full Text: $_fullScannedText',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Card Number: ${_scannedCardNumber ?? "Not detected"}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _scannedCardNumber != null
                                          ? Colors.green
                                          : Colors.red,
                                ),
                              ),
                              if (_scannedCardNumber != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Card Type: $_scannedCardType',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                              if (_scannedCVV?.isNotEmpty ?? false) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'CVV: $_scannedCVV',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                              if (_scannedExpiryMonth?.isNotEmpty ?? false) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Expiry: ${_scannedExpiryMonth}/${_scannedExpiryYear}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                              if (_scannedCardHolder?.isNotEmpty ?? false) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Card Holder: $_scannedCardHolder',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.credit_card, size: 60, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('No image selected'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              if (_isProcessing) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                const Text('Processing...'),
                const SizedBox(height: 30),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      onPressed: () => _pickImage(ImageSource.camera),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(150, 50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      onPressed: () => _pickImage(ImageSource.gallery),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(150, 50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_imageFile != null)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Another Image'),
                        onPressed: _resetScan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          minimumSize: const Size(200, 50),
                        ),
                      ),
                    if (_fullScannedText != null &&
                        _scannedCardNumber == null) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.info),
                        label: const Text('Manual Entry from OCR'),
                        onPressed: () => _manualEntryFromOcr(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: const Size(200, 50),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _manualEntryFromOcr() {
    if (_fullScannedText == null) return;

    // OCR text
    String allDigits = _fullScannedText!.replaceAll(RegExp(r'\D'), '');
    List<String> potentialNumbers = [];

    // Look for sequences of 13-19 digits
    for (int i = 0; i <= allDigits.length - 13; i++) {
      for (int length = 13; length <= 19; length++) {
        if (i + length <= allDigits.length) {
          potentialNumbers.add(allDigits.substring(i, i + length));
        }
      }
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Card Number'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: potentialNumbers.length,
                itemBuilder: (context, index) {
                  String number = potentialNumbers[index];
                  return ListTile(
                    title: Text(number),
                    subtitle: Text(
                      '${number.length} digits - ${getCardType(number)}',
                    ),
                    onTap: () {
                      // Extract other details when user selects a card number
                      String cvv = OcrUtils.extractCVV(_fullScannedText!);
                      Map<String, String> expiryDate =
                          OcrUtils.extractExpiryDate(_fullScannedText!);
                      String cardHolder = OcrUtils.extractCardHolder(
                        _fullScannedText!,
                      );

                      setState(() {
                        _scannedCardNumber = number;
                        _scannedCardType = getCardType(number);
                        _scannedCVV = cvv;
                        _scannedExpiryMonth = expiryDate['month'];
                        _scannedExpiryYear = expiryDate['year'];
                        _scannedCardHolder = cardHolder;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }
}
