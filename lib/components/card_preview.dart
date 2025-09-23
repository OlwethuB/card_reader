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
    _cvvController.text = widget.cvv;
    _expiryMonthController.text = widget.expiryMonth;
    _expiryYearController.text = widget.expiryYear;
    _cardHolderController.text = widget.cardHolder;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Card Details',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Number
                TextFormField(
                  initialValue: widget.cardNumber,
                  readOnly: true,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Card Number',
                    prefixIcon: Icon(Icons.credit_card),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Card Type
                TextFormField(
                  initialValue: widget.cardType,
                  readOnly: true,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Card Type',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // Card Holder
                TextFormField(
                  controller: _cardHolderController,
                  decoration: const InputDecoration(
                    labelText: 'Card Holder Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Expiry Date Row
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
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('/', style: TextStyle(fontSize: 18)),
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
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // CVV
                TextFormField(
                  controller: _cvvController,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
                const SizedBox(height: 16),

                // Issuing Country
                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Issuing Country',
                    prefixIcon: Icon(Icons.public),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
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
                  icon: const Icon(Icons.save),
                  label: const Text("Save Card"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(6), ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onRescan,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text("Rescan"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(6), ),
                  ),
                ),
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