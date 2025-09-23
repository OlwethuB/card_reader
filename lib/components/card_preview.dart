import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardPreview extends StatefulWidget {
  final String cardNumber;
  final String cardType;
  final String cvv;
  final String expiryMonth;
  final String expiryYear;
  final String cardHolder;
  final Function(String, String, String, String, String) onSave;
  final VoidCallback onRescan;

  const CardPreview({
    super.key,
    required this.cardNumber,
    required this.cardType,
    required this.cvv,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardHolder,
    required this.onSave,
    required this.onRescan,
  });

  @override
  State<CardPreview> createState() => _CardPreviewState();
}

class _CardPreviewState extends State<CardPreview> {
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _expiryMonthController = TextEditingController(); 
  final TextEditingController _expiryYearController = TextEditingController(); 
  final TextEditingController _cardHolderController = TextEditingController(); 

  @override
  void initState() {
    super.initState();
    // Pre-fill detected values
    _cvvController.text = widget.cvv;
    _expiryMonthController.text = widget.expiryMonth;
    _expiryYearController.text = widget.expiryYear;
    _cardHolderController.text = widget.cardHolder;
  }

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
                  
                  // Card Holder Field
                  TextFormField(
                    controller: _cardHolderController,
                    decoration: const InputDecoration(
                      labelText: 'Card Holder Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter card holder name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Expiry Date Fields
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _expiryMonthController,
                          decoration: const InputDecoration(
                            labelText: 'MM',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Month required';
                            }
                            int month = int.tryParse(value) ?? 0;
                            if (month < 1 || month > 12) {
                              return 'Invalid month';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('/', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _expiryYearController,
                          decoration: const InputDecoration(
                            labelText: 'YYYY',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Year required';
                            }
                            int year = int.tryParse(value) ?? 0;
                            if (year < DateTime.now().year) {
                              return 'Card expired';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // CVV Field
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
                  
                  // Country Field
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
                      (_cvvController.text.length == 3 || _cvvController.text.length == 4) &&
                      _expiryMonthController.text.isNotEmpty &&
                      _expiryYearController.text.isNotEmpty &&
                      _cardHolderController.text.isNotEmpty) {
                    widget.onSave(
                      _countryController.text, 
                      _cvvController.text,
                      _expiryMonthController.text,
                      _expiryYearController.text,
                      _cardHolderController.text,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all required fields')),
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
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }
}