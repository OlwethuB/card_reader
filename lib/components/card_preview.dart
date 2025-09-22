import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardPreview extends StatefulWidget {
  final String cardNumber;
  final String cardType;
  final Function(String, String) onSave; // Changed to accept both country and CVV
  final VoidCallback onRescan;

  const CardPreview({
    super.key,
    required this.cardNumber,
    required this.cardType,
    required this.onSave,
    required this.onRescan,
  });

  @override
  State<CardPreview> createState() => _CardPreviewState();
}

class _CardPreviewState extends State<CardPreview> {
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Card Number: ${widget.cardNumber}'),
                  Text('Card Type: ${widget.cardType}'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cvvController,
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter CVV';
                      }
                      if (value.length < 3 || value.length > 4) {
                        return 'CVV must be 3 or 4 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Issuing Country',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter issuing country';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (_countryController.text.isNotEmpty && 
                      (_cvvController.text.length == 3 || _cvvController.text.length == 4)) {
                    widget.onSave(_countryController.text, _cvvController.text);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter valid CVV and country')),
                    );
                  }
                },
                child: const Text('Save Card'),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: widget.onRescan,
                child: const Text('Rescan'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _countryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
}