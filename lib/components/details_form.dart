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
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.grey.withOpacity(0.05),
                //     blurRadius: 10,
                //     spreadRadius: 2,
                //   ),
                // ],
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Card Number',
                      prefixIcon: Icon(Icons.credit_card),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _inferCardType(),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter card number';
                      if (!isValidCardNumber(value)) return 'Invalid card number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _cardTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Card Type',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Card type could not be determined' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _cardHolderController,
                    decoration: const InputDecoration(
                      labelText: 'Card Holder Name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Please enter card holder name' : null,
                  ),
                  const SizedBox(height: 16),

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
                            if (value == null || value.isEmpty) return 'Month required';
                            int month = int.tryParse(value) ?? 0;
                            if (month < 1 || month > 12) return 'Invalid month';
                            return null;
                          },
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
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Year required';
                            int year = int.tryParse(value) ?? 0;
                            if (year < DateTime.now().year) return 'Card expired';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

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
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter CVV';
                      if (value.length < 3 || value.length > 4) return 'CVV must be 3 or 4 digits';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Issuing Country',
                      prefixIcon: Icon(Icons.public),
                      border: OutlineInputBorder(),
                    ),
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

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _formKey.currentState!.reset();
                    _cardNumberController.clear();
                    _cardTypeController.clear();
                    _cvvController.clear();
                    _countryController.clear();
                    _cardHolderController.clear();
                    _expiryMonthController.clear();
                    _expiryYearController.clear();
                  },
                  icon: const Icon(Icons.restart_alt),
                  label: const Text("Reset"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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