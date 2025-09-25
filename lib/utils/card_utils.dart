import 'package:card_reader/providers/credit_card_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String getCardType(String cardNumber) {
  // Remove any non-digit characters
  String cleanedNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
  
  if (cleanedNumber.isEmpty) return 'Unknown';
  
  // Visa: starts with 4
  if (RegExp(r'^4').hasMatch(cleanedNumber)) return 'Visa';
  
  // MasterCard: starts with 51-55 or 2221-2720
  if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(cleanedNumber)) return 'MasterCard';
  
  // American Express: starts with 34 or 37
  if (RegExp(r'^3[47]').hasMatch(cleanedNumber)) return 'American Express';
  
  // Discover: starts with 6011, 65, or 644-649
  if (RegExp(r'^(6011|65|64[4-9])').hasMatch(cleanedNumber)) return 'Discover';
  
  // Diners Club: starts with 300-305, 36, or 38
  if (RegExp(r'^(30[0-5]|36|38)').hasMatch(cleanedNumber)) return 'Diners Club';
  
  // JCB: starts with 2131, 1800, or 35
  if (RegExp(r'^(2131|1800|35)').hasMatch(cleanedNumber)) return 'JCB';
  
  return 'Unknown';
}

bool isValidCardNumber(String cardNumber) {
  // Remove any non-digit characters
  String cleanedNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
  
  // Check if it's empty or too short
  if (cleanedNumber.isEmpty || cleanedNumber.length < 13) return false;
  
  // Luhn algorithm validation
  int sum = 0;
  bool alternate = false;
  
  for (int i = cleanedNumber.length - 1; i >= 0; i--) {
    int digit = int.parse(cleanedNumber[i]);
    
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

Future<bool> isCardAlreadySaved(String cardNumber, WidgetRef ref) async {
  final cards = ref.read(creditCardsProvider);
  return cards.any((card) => card.cardNumber == cardNumber);
}

void showCardExistsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Card Already Exists'),
      content: const Text('This card has already been saved.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

void showCountryDeniedDialog(BuildContext context, String country) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Card Country is not accepted.'),
      content: Text('Cards from $country are not accepted'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}