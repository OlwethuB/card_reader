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
              onPressed: () { _showClearAllDialog(context, ref); },
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
                    margin: const EdgeInsets.symmetric( horizontal: 16, vertical: 8,),
                    child: ListTile(
                      title: Text( '${card.cardType} •••• ${card.cardNumber.substring(card.cardNumber.length - 4)}', ),
                      subtitle: Text('Issuing Country: ${card.issuingCountry}'),
                      leading: card.frontImagePath != null
                        ? Image.file( File(card.frontImagePath!), width: 40, height: 40, fit: BoxFit.cover, )
                        : const Icon(Icons.credit_card),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (card.frontImagePath != null ||
                              card.backImagePath != null)
                            IconButton(
                              icon: const Icon(Icons.photo_library),
                              onPressed: () { _showCardImages(context, card); },
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              ref.read(creditCardsProvider.notifier).deleteCard(card.id);
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

  void _showCardImages(BuildContext context, CreditCard card) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: const Text('Card Images'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (card.frontImagePath != null) ...[
                        const Text(
                          'Front:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Image.file(File(card.frontImagePath!)),
                        const SizedBox(height: 16),
                      ],
                      if (card.backImagePath != null) ...[
                        const Text(
                          'Back:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Image.file(File(card.backImagePath!)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
