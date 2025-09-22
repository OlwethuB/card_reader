import 'package:card_reader/models/credit_card.dart';
import 'package:card_reader/providers/credit_card_provider.dart';
import 'package:card_reader/utils/card_utils.dart';
import 'package:card_reader/utils/country_utils.dart';
import 'package:flutter/material.dart';
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

      // Check if country is banned
      if (isCountryBanned(country)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cards from $country are not accepted')),
        );
        return;
      }

      // Check if card number is valid
      if (!isValidCardNumber(cardNumber)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid card number')),
        );
        return;
      }

      // Check if card already exists
      final cardExists = await ref.read(creditCardsProvider.notifier).doesCardExist(cardNumber);
      if (cardExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This card has already been saved')),
        );
        return;
      }

      // Create new card
      final newCard = CreditCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cardNumber: cardNumber,
        cardType: cardType,
        cvv: cvv,
        issuingCountry: country,
        createdAt: DateTime.now(),
      );

      // Add card using provider
      ref.read(creditCardsProvider.notifier).addCard(newCard);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card saved successfully')),
      );

      // Reset form
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _cardNumberController,
              decoration: const InputDecoration(
                labelText: 'Card Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _inferCardType(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter card number';
                }
                if (!isValidCardNumber(value)) {
                  return 'Invalid card number';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _cardTypeController,
              decoration: const InputDecoration(
                labelText: 'Card Type',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Card type could not be determined';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _cvvController,
              decoration: const InputDecoration(
                labelText: 'CVV',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
            const SizedBox(height: 18),
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
                if (isCountryBanned(value)) {
                  return 'Cards from this country are not accepted';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    _formKey.currentState!.reset();
                    _cardNumberController.clear();
                    _cardTypeController.clear();
                    _cvvController.clear();
                    _countryController.clear();
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardTypeController.dispose();
    _cvvController.dispose();
    _countryController.dispose();
    super.dispose();
  }
}