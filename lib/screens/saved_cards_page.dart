import 'dart:io';

import 'package:card_reader/models/credit_card.dart';
import 'package:card_reader/providers/credit_card_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SavedCardsPage extends ConsumerWidget {
  const SavedCardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CreditCard> cards = ref.watch(creditCardsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Saved Cards"),
        actions: [
          if (cards.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _showClearAllDialog(context, ref);
              },
            ),
        ],
      ),
      body:
          cards.isEmpty
              ? const Center(child: Text('No cards saved yet'))
              : ListView.builder(
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        '${card.cardType} •••• ${card.cardNumber.substring(card.cardNumber.length - 4)}',
                      ),
                      subtitle: Text('Issuing Country: ${card.issuingCountry}'),
                      leading: const Icon(Icons.credit_card),
                      onTap: () => _showCardDetailsDialog(context, card),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              ref
                                  .read(creditCardsProvider.notifier)
                                  .deleteCard(card.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Cards'),
          content: const Text(
            'Are you sure you want to delete all saved cards?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Delete all cards
                final cards = ref.read(creditCardsProvider);
                for (final card in cards) {
                  ref.read(creditCardsProvider.notifier).deleteCard(card.id);
                }
                Navigator.pop(context);
              },
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );
  }

  void _showCardDetailsDialog(BuildContext context, CreditCard card) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Top Row: Country + Card Type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        card.issuingCountry,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        card.cardType,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  /// Card Number (centered)
                  Text(
                    card.cardNumber,
                    style: const TextStyle(
                      fontSize: 18,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  /// CVV + Expiry
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CVV: ${card.cvv}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Exp: ${card.expiryMonth}/${card.expiryYear}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  /// Card Holder
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      card.cardHolder,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
    );
  }
}
