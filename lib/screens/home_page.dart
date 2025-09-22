import 'package:card_reader/components/details_form.dart';
import 'package:card_reader/components/scan_camera.dart';
import 'package:card_reader/models/credit_card.dart';
import 'package:card_reader/providers/credit_card_provider.dart';
import 'package:card_reader/screens/saved_cards_page.dart';
import 'package:card_reader/utils/country_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override 
  void initState() {
    super.initState();
    // Load cards when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(creditCardsProvider.notifier).loadCards();
    });
  }

  void _handleScannedCard(Map<String, dynamic>? cardData) async {
    if (cardData != null) {
      final cardNumber = cardData['cardNumber'] as String;
      final cardType = cardData['cardType'] as String;
      final country = cardData['country'] as String;
      final cvv = cardData['cvv'] as String;
      
      // Check if card already exists
      final cardExists = await ref.read(creditCardsProvider.notifier).doesCardExist(cardNumber);
      if (cardExists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This card has already been saved')),
          );
        }
        return;
      }
      
      // Check if country is banned
      if (isCountryBanned(country)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cards from $country are not accepted')),
          );
        }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card saved successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Card Details Reader"),
          // Left Side
          actions: <Widget>[
            //IconButton
            IconButton(
              icon: const Icon(Icons.credit_card),
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => const SavedCardsPage(),
                  ),
                );
              },
            ),
          ],
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          elevation: 50.0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,

          bottom: const TabBar(
            indicatorColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.edit), text: "Manual Entry"),
              Tab(icon: Icon(Icons.camera_alt), text: "Scan Card"),
            ],
          ),// TabBar
        ), // AppBar

        body: TabBarView(
          children: [
            DetailsForm(), // The Details form
            ScanCamera(onCardScanned: _handleScannedCard), // The Camera scan
          ],
        ), // TabBarView
      ), // Scaffold
    );
  }
}