import 'package:card_reader/components/shared/action_button.dart';
import 'package:card_reader/components/shared/card_input_field.dart';
import 'package:card_reader/components/shared/expiry_date_input.dart';
import 'package:card_reader/models/credit_card.dart';
import 'package:card_reader/providers/credit_card_provider.dart';
import 'package:card_reader/utils/card_utils.dart';
import 'package:card_reader/utils/country_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailsForm extends ConsumerStatefulWidget {
  const DetailsForm({super.key});

  @override
  ConsumerState<DetailsForm> createState() => _DetailsFormState();
}

class _DetailsFormState extends ConsumerState<DetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardTypeController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryMonthController = TextEditingController();
  final TextEditingController _expiryYearController = TextEditingController();

  void _inferCardType() {
    final cardNumber = _cardNumberController.text;
    if (cardNumber.isNotEmpty) {
      final cardType = getCardType(cardNumber);
      _cardTypeController.text = cardType;
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final cardNumber = _cardNumberController.text;
      final cardType = _cardTypeController.text;
      final cvv = _cvvController.text;
      final country = _countryController.text;
      final cardHolder = _cardHolderController.text;
      final expiryMonth = _expiryMonthController.text;
      final expiryYear = _expiryYearController.text;

      if (isCountryBanned(country)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cards from $country are not accepted')),
        );
        return;
      }

      if (!isValidCardNumber(cardNumber)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid card number')),
        );
        return;
      }

      final cardExists = await ref.read(creditCardsProvider.notifier).doesCardExist(cardNumber);
      if (cardExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This card has already been saved')),
        );
        return;
      }

      final newCard = CreditCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cardNumber: cardNumber,
        cardType: cardType,
        cvv: cvv,
        issuingCountry: country,
        createdAt: DateTime.now(),
        cardHolder: cardHolder,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
      );

      ref.read(creditCardsProvider.notifier).addCard(newCard);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card saved successfully')),
      );

      _formKey.currentState!.reset();
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _cardNumberController.clear();
    _cardTypeController.clear();
    _cvvController.clear();
    _countryController.clear();
    _cardHolderController.clear();
    _expiryMonthController.clear();
    _expiryYearController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Details Form',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  // Card Number Field
                  CardInputField(
                    controller: _cardNumberController,
                    labelText: 'Card Number',
                    prefixIcon: Icons.credit_card,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _inferCardType(),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter card number';
                      if (!isValidCardNumber(value)) return 'Invalid card number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Card Type Field
                  CardInputField(
                    controller: _cardTypeController,
                    labelText: 'Card Type',
                    prefixIcon: Icons.category,
                    readOnly: true,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Card type could not be determined' : null,
                  ),
                  const SizedBox(height: 16),

                  // Card Holder Field
                  CardInputField(
                    controller: _cardHolderController,
                    labelText: 'Card Holder Name',
                    prefixIcon: Icons.person_outline,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Please enter card holder name' : null,
                  ),
                  const SizedBox(height: 16),

                  // Expiry Date Fields
                  ExpiryDateInput(
                    monthController: _expiryMonthController,
                    yearController: _expiryYearController,
                  ),
                  const SizedBox(height: 16),

                  // CVV Field
                  CardInputField(
                    controller: _cvvController,
                    labelText: 'CVV',
                    prefixIcon: Icons.lock_outline,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter CVV';
                      if (value.length < 3 || value.length > 4) return 'CVV must be 3 or 4 digits';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Country Field
                  CardInputField(
                    controller: _countryController,
                    labelText: 'Issuing Country',
                    prefixIcon: Icons.public,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter issuing country';
                      if (isCountryBanned(value)) return 'Cards from this country are not accepted';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              ActionButton(
                onPressed: _submitForm,
                label: "Save",
                icon: Icons.save,
                isPrimary: true,
              ),
              const SizedBox(width: 16),
              ActionButton(
                onPressed: _resetForm,
                label: "Reset",
                icon: Icons.restart_alt,
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
    _cardNumberController.dispose();
    _cardTypeController.dispose();
    _cvvController.dispose();
    _countryController.dispose();
    _cardHolderController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    super.dispose();
  }
}