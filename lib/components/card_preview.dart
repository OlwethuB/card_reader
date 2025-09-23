import 'package:card_reader/components/shared/action_button.dart';
import 'package:card_reader/components/shared/card_input_field.dart';
import 'package:card_reader/components/shared/expiry_date_input.dart';
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

  void _handleSave() {
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
                CardInputField(
                  initialValue: widget.cardNumber,
                  labelText: 'Card Number',
                  prefixIcon: Icons.credit_card,
                  readOnly: true,
                  enabled: false,
                ),
                const SizedBox(height: 16),

                // Card Type
                CardInputField(
                  initialValue: widget.cardType,
                  labelText: 'Card Type',
                  prefixIcon: Icons.category,
                  readOnly: true,
                  enabled: false,
                ),
                const SizedBox(height: 24),

                // Card Holder
                CardInputField(
                  controller: _cardHolderController,
                  labelText: 'Card Holder Name',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 16),

                // Expiry Date
                ExpiryDateInput(
                  monthController: _expiryMonthController,
                  yearController: _expiryYearController,
                ),
                const SizedBox(height: 16),

                // CVV
                CardInputField(
                  controller: _cvvController,
                  labelText: 'CVV',
                  prefixIcon: Icons.lock_outline,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
                const SizedBox(height: 16),

                // Issuing Country
                CardInputField(
                  controller: _countryController,
                  labelText: 'Issuing Country',
                  prefixIcon: Icons.public,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              ActionButton(
                onPressed: _handleSave,
                label: "Save Card",
                icon: Icons.save,
                isPrimary: true,
              ),
              const SizedBox(width: 16),
              ActionButton(
                onPressed: widget.onRescan,
                label: "Rescan",
                icon: Icons.camera_alt_outlined,
                isPrimary: false,
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