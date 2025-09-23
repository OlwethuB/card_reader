class CreditCard {
  final String id;
  final String cardNumber;
  final String cardType;
  final String cvv;
  final String issuingCountry;
  final DateTime createdAt;
  final String cardHolder;
  final String expiryMonth;
  final String expiryYear;

  CreditCard({
    required this.id, 
    required this.cardNumber, 
    required this.cardType, 
    required this.cvv, 
    required this.issuingCountry, 
    required this.createdAt,
    required this.cardHolder,
    required this.expiryMonth,
    required this.expiryYear,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cardNumber': cardNumber,
      'cardType': cardType,
      'cvv': cvv,
      'issuingCountry': issuingCountry,
      'createdAt': createdAt.toIso8601String(),
      'cardHolder': cardHolder,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
    };
  }

  factory CreditCard.fromMap(Map<String, dynamic> map) {
    return CreditCard(
      id: map['id'] ?? '', 
      cardNumber: map['cardNumber'] ?? '', 
      cardType: map['cardType'] ?? '', 
      cvv: map['cvv'] ?? '', 
      issuingCountry: map['issuingCountry'] ?? '', 
      createdAt: DateTime.parse(map['createdAt']) ?? DateTime.now(),
      cardHolder: map['cardHolder'] ?? '', 
      expiryMonth: map['expiryMonth'] ?? '', 
      expiryYear: map['expiryYear'] ?? '', 
    );
  }

  CreditCard copyWith({
    String? id,
    String? cardNumber,
    String? cardType,
    String? cvv,
    String? issuingCountry,
    DateTime? createdAt,
    String? cardHolder,
    String? expiryMonth,
    String? expiryYear,
  }) {
    return CreditCard(
      id: id ?? this.id, 
      cardNumber: cardNumber ?? this.cardNumber, 
      cardType: cardType ?? this.cardType, 
      cvv: cvv ?? this.cvv, 
      issuingCountry: issuingCountry ?? this.issuingCountry, 
      createdAt: createdAt ?? this.createdAt,
      cardHolder: cardHolder ?? this.cardHolder, 
      expiryMonth: expiryMonth ?? this.expiryMonth, 
      expiryYear: expiryYear ?? this.expiryYear, 
    );
  }
}