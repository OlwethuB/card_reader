import 'dart:convert';
import 'dart:io';
import 'package:card_reader/models/credit_card.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static const String _cardsKey = 'saved_cards';
  
  static Future<void> saveCard(CreditCard card) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existingCards = prefs.getStringList(_cardsKey) ?? [];
    
    // Check if card already exists
    for (String cardJson in existingCards) {
      final existingCard = CreditCard.fromMap(Map<String, dynamic>.from(json.decode(cardJson)));
      if (existingCard.cardNumber == card.cardNumber) {
        throw Exception('Card already exists');
      }
    }
    
    existingCards.add(json.encode(card.toMap()));
    await prefs.setStringList(_cardsKey, existingCards);
  }
  
  static Future<List<CreditCard>> getCards() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? cardsJson = prefs.getStringList(_cardsKey);
    
    if (cardsJson == null) return [];
    
    return cardsJson.map((jsonString) {
      return CreditCard.fromMap(Map<String, dynamic>.from(json.decode(jsonString)));
    }).toList();
  }
  
  static Future<void> deleteCard(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existingCards = prefs.getStringList(_cardsKey) ?? [];
    
    final updatedCards = existingCards.where((cardJson) {
      final card = CreditCard.fromMap(Map<String, dynamic>.from(json.decode(cardJson)));
      return card.id != id;
    }).toList();
    
    await prefs.setStringList(_cardsKey, updatedCards);
  }
  
  static Future<void> updateCard(CreditCard updatedCard) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existingCards = prefs.getStringList(_cardsKey) ?? [];
    
    final updatedCards = existingCards.map((cardJson) {
      final card = CreditCard.fromMap(Map<String, dynamic>.from(json.decode(cardJson)));
      return card.id == updatedCard.id ? json.encode(updatedCard.toMap()) : cardJson;
    }).toList();
    
    await prefs.setStringList(_cardsKey, updatedCards);
  }
  
  // Helper method to check if a card exists by number
  static Future<bool> doesCardExist(String cardNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? cardsJson = prefs.getStringList(_cardsKey);
    
    if (cardsJson == null) return false;
    
    for (String cardJson in cardsJson) {
      final card = CreditCard.fromMap(Map<String, dynamic>.from(json.decode(cardJson)));
      if (card.cardNumber == cardNumber) {
        return true;
      }
    }
    
    return false;
  }

static Future<String> _saveImageToStorage(File imageFile, String cardId, String side) async {
  final Directory extDir = await getApplicationDocumentsDirectory();
  final String dirPath = path.join(extDir.path, 'card_images', cardId);
  await Directory(dirPath).create(recursive: true);
  
  final String filePath = path.join(dirPath, '$side${DateTime.now().millisecondsSinceEpoch}.jpg');
  final File savedImage = await imageFile.copy(filePath);
  
  return savedImage.path;
}

static Future<void> saveCardWithImages(CreditCard card, {File? frontImage, File? backImage}) async {
  String? frontImagePath;
  String? backImagePath;

  if (frontImage != null) {
    frontImagePath = await _saveImageToStorage(frontImage, card.id, 'front');
  }

  if (backImage != null) {
    backImagePath = await _saveImageToStorage(backImage, card.id, 'back');
  }

  final cardWithImages = card.copyWith(
    frontImagePath: frontImagePath,
    backImagePath: backImagePath,
  );

  await saveCard(cardWithImages);
}

}