import 'dart:io';

import 'package:card_reader/models/credit_card.dart';
import 'package:card_reader/utils/storage_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreditCardsNotifier extends StateNotifier<List<CreditCard>> {
  CreditCardsNotifier() : super([]);

  Future<void> loadCards() async {
    final cards = await StorageHelper.getCards();
    state = cards; 
  }

  Future<void> addCard(CreditCard card) async {
    // Load the latest cards from storage to ensure we have the most current data
    final currentCards = await StorageHelper.getCards();
    
    // Check for duplicates in the actual storage, not just current state
    if (currentCards.any((existingCard) => existingCard.cardNumber == card.cardNumber)) {
      // Show error message
      return;
    }

    await StorageHelper.saveCard(card);
    await loadCards(); // reload from storage
  }

  Future<void> deleteCard(String id) async {
    await StorageHelper.deleteCard(id);
    await loadCards();
  }

  Future<void> updateCard(CreditCard updatedCard) async {
    await StorageHelper.updateCard(updatedCard);
    await loadCards();
  }
  
  // Helper method to check if a card already exists
  Future<bool> doesCardExist(String cardNumber) async {
    return await StorageHelper.doesCardExist(cardNumber);
  }

  Future<void> addCardWithImages(
  CreditCard card, {
  File? frontImage,
  File? backImage,
}) async {
  // Check for duplicates
  final currentCards = await StorageHelper.getCards();
  if (currentCards.any((existingCard) => existingCard.cardNumber == card.cardNumber)) {
    return;
  }

  await StorageHelper.saveCardWithImages(
    card,
    frontImage: frontImage,
    backImage: backImage,
  );
  await loadCards(); // reload from storage
}
}

final creditCardsProvider = StateNotifierProvider<CreditCardsNotifier, List<CreditCard>>((ref) {
  return CreditCardsNotifier();
});